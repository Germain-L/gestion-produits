#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Check if k6 is installed
try {
  execSync('which k6', { stdio: 'ignore' });
} catch (e) {
  console.error('Error: k6 is not installed. Please install k6 from https://k6.io/docs/get-started/installation/');
  process.exit(1);
}

const TEST_CONFIGS = [
  { profile: 'light', repeats: 2, name: 'baseline' },
  { profile: 'medium', repeats: 2, name: 'normal-load' },
  { profile: 'heavy', repeats: 1, name: 'peak-load' }
];

const RESULTS_DIR = './test-results';
const SUMMARY_FILE = path.join(RESULTS_DIR, 'test-summary.md');

// Create results directory if it doesn't exist
if (!fs.existsSync(RESULTS_DIR)) {
  fs.mkdirSync(RESULTS_DIR, { recursive: true });
}

// Initialize summary file
fs.writeFileSync(SUMMARY_FILE, '# Load Test Results Summary\n\n', 'utf8');

function appendToSummary(content) {
  fs.appendFileSync(SUMMARY_FILE, content + '\n', 'utf8');
}

// Function to parse test results
function parseTestResults(filePath) {
  try {
    const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    return {
      metrics: data.metrics,
      timestamp: new Date(data.metrics.timestamp.values.count * 1000).toISOString(),
      duration: `${(data.metrics.test_duration.values.avg / 1000).toFixed(2)}s`,
      iterations: data.metrics.iterations.count,
      http_req_failed: `${(data.metrics.http_req_failed.values.rate * 100).toFixed(2)}%`,
      http_req_duration: {
        avg: `${data.metrics.http_req_duration.values.avg.toFixed(2)}ms`,
        p95: `${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms`,
        max: `${data.metrics.http_req_duration.values.max.toFixed(2)}ms`
      }
    };
  } catch (e) {
    console.error(`Error parsing results from ${filePath}:`, e.message);
    return null;
  }
}

// Run all tests
async function runTests() {
  const results = [];
  
  for (const config of TEST_CONFIGS) {
    console.log(`\n=== Running ${config.repeats} test(s) with profile: ${config.profile} (${config.name}) ===\n`);
    
    for (let i = 1; i <= config.repeats; i++) {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const resultFile = path.join(RESULTS_DIR, `${config.name}-${i}-${timestamp}.json`);
      
      console.log(`Starting test run ${i}/${config.repeats}...`);
      
      try {
        execSync(`k6 run --env TEST_PROFILE=${config.profile} --out json=${resultFile} stress-test.js`, {
          stdio: 'inherit',
          cwd: __dirname
        });
        
        // Parse and store results
        const result = parseTestResults(resultFile);
        if (result) {
          results.push({
            config,
            resultFile,
            ...result
          });
        }
        
        console.log(`Test completed. Results saved to ${resultFile}`);
      } catch (error) {
        console.error(`Test failed: ${error.message}`);
      }
      
      // Add a small delay between tests
      if (i < config.repeats) {
        console.log('Waiting 10 seconds before next test...');
        await new Promise(resolve => setTimeout(resolve, 10000));
      }
    }
  }
  
  return results;
}

// Generate summary report
function generateSummary(results) {
  appendToSummary('## Test Execution Summary\n');
  
  const summaryTable = [
    '| Test Name | Profile | Iterations | Duration | Failed Requests | Avg Response Time | p95 Response Time |',
    '|-----------|---------|------------|----------|-----------------|------------------|-------------------|'
  ];
  
  results.forEach(({ config, resultFile, timestamp, duration, iterations, http_req_failed, http_req_duration }) => {
    const testName = path.basename(resultFile, '.json');
    const relativePath = path.relative(process.cwd(), resultFile);
    
    summaryTable.push(
      `| [${testName}](${relativePath}) | ${config.profile} | ${iterations} | ${duration} | ${http_req_failed} | ${http_req_duration.avg} | ${http_req_duration.p95} |`
    );
  });
  
  appendToSummary(summaryTable.join('\n') + '\n');
  
  // Add detailed metrics section
  appendToSummary('## Detailed Metrics\n');
  results.forEach(({ config, resultFile, metrics }) => {
    const testName = path.basename(resultFile, '.json');
    appendToSummary(`### ${testName} (${config.profile})\n`);
    
    // Add a table with key metrics
    const metricsTable = [
      '| Metric | Value |',
      '|--------|-------|',
      `| Test Duration | ${(metrics.test_duration.values.avg / 1000).toFixed(2)}s |`,
      `| Iterations | ${metrics.iterations.count} |`,
      `| VUs (max) | ${metrics.vus.values.max} |`,
      `| HTTP Requests | ${metrics.http_reqs.count} |`,
      `| Failed Requests | ${(metrics.http_req_failed.values.rate * 100).toFixed(2)}% |`,
      `| Avg. Response Time | ${metrics.http_req_duration.values.avg.toFixed(2)}ms |`,
      `| p(95) Response Time | ${metrics.http_req_duration.values['p(95)'].toFixed(2)}ms |`,
      `| Data Received | ${(metrics.data_received.values.count / 1024 / 1024).toFixed(2)} MB |`,
      `| Data Sent | ${(metrics.data_sent.values.count / 1024).toFixed(2)} KB |`
    ];
    
    appendToSummary(metricsTable.join('\n') + '\n');
  });
  
  console.log(`\n=== Test summary saved to ${SUMMARY_FILE} ===\n`);
}

// Main function
async function main() {
  try {
    const results = await runTests();
    generateSummary(results);
    console.log('All tests completed successfully!');
  } catch (error) {
    console.error('Error running tests:', error);
    process.exit(1);
  }
}

main();
