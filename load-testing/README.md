# Load Testing with k6

This directory contains load testing scripts for the Gestion Produits application using [k6](https://k6.io/).

## Prerequisites

- [k6](https://k6.io/docs/get-started/installation/) installed on your system

## Directory Structure

- `batch-test.js`: Main script to run tests with different profiles
- `stress-test.js`: k6 test script with sample test scenarios
- `test-results/`: Directory where test results are stored
- `README.md`: This documentation file

## Available Test Profiles

The batch test includes three different test profiles:

1. **light**: 10 virtual users for 30 seconds (baseline)
2. **medium**: 25 virtual users for 1 minute (normal load)
3. **heavy**: 50 virtual users for 2 minutes (peak load)

## Running Tests

1. Ensure your application is running (default: http://localhost:8080)
2. Navigate to the load-testing directory:

   ```bash
   cd load-testing
   ```
3. Make the batch script executable:

   ```bash
   chmod +x batch-test.js
   ```

4. Run the batch test:

   ```bash
   ./batch-test.js
   ```

   Or using Node.js if you have it installed:

   ```bash
   node batch-test.js
   ```

## Running Individual Tests

You can also run individual test profiles directly with k6:

```bash
# Light load test
k6 run --env TEST_PROFILE=light stress-test.js

# Medium load test
k6 run --env TEST_PROFILE=medium stress-test.js

# Heavy load test
k6 run --env TEST_PROFILE=heavy stress-test.js
```

## Test Results

After running the tests, you'll find:
- Individual test results in JSON format in the `test-results/` directory
- A summary report in Markdown format at `test-results/test-summary.md`

## Customizing Tests

1. Edit `stress-test.js` to modify test scenarios and endpoints
2. Update test profiles in `batch-test.js` (TEST_CONFIGS array)
3. Adjust thresholds and assertions as needed

## Viewing Results

The summary report includes:
- Test execution summary
- Detailed metrics for each test run
- Links to individual test result files

For more detailed analysis, you can use k6's built-in output options or third-party tools compatible with k6's JSON output format.
