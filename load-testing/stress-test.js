import http from 'k6/http';
import { sleep, check } from 'k6';

// Load test configuration based on profile
const profiles = {
  light: { vus: 10, duration: '30s' },
  medium: { vus: 25, duration: '1m' },
  heavy: { vus: 50, duration: '2m' }
};

// Get the test profile from environment variable
const profile = __ENV.TEST_PROFILE || 'light';
const config = profiles[profile] || profiles.light;

export const options = {
  vus: config.vus,
  duration: config.duration,
  thresholds: {
    http_req_failed: ['rate<0.1'], // Less than 10% of requests should fail
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
  },
};

// Base URL for your application
const BASE_URL = 'http://localhost:8080';

export default function () {
  // Example: Test product listing endpoint
  const productListRes = http.get(`${BASE_URL}/api/products`);
  
  // Example: Test product detail endpoint
  const productId = Math.floor(Math.random() * 100) + 1; // Random product ID between 1-100
  const productDetailRes = http.get(`${BASE_URL}/api/products/${productId}`);
  
  // Add more test scenarios as needed
  
  // Add some delay between requests
  sleep(1);
  
  // Add checks for responses
  check(productListRes, {
    'Product list status is 200': (r) => r.status === 200,
  });
  
  check(productDetailRes, {
    'Product detail status is 200': (r) => r.status === 200,
  });
}
