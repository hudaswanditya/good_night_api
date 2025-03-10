import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://localhost:3000/api/v1';

export let options = {
  stages: [
    { duration: '10s', target: 500 },
    { duration: '30s', target: 1000 },
    { duration: '10s', target: 0 }
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  let userId = Math.floor(Math.random() * 10000) + 1;

  let usersRes = http.get(`${BASE_URL}/users`);
  check(usersRes, { 'Users list: status 200': (r) => r.status === 200 });

  let userRes = http.get(`${BASE_URL}/users/${userId}`);
  check(userRes, { 'User details: status 200 or 404': (r) => r.status === 200 || r.status === 404 });

  let sleepRecordsRes = http.get(`${BASE_URL}/users/${userId}/following_sleep_records`);
  check(sleepRecordsRes, { 'Sleep records: status 200': (r) => r.status === 200 || r.status === 404 });

  sleep(1); // Simulate real-world delay
}
