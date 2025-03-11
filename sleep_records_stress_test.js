import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://localhost:3000/api/v1';
const HEADERS = { headers: { 'accept': '*/*' } };

export let options = {
  stages: [
    { duration: '20s', target: 50 },
    { duration: '40s', target: 100 },
    { duration: '40s', target: 50 },
    { duration: '20s', target: 0 }
  ],
  thresholds: {
    http_req_duration: ['p(95)<700'],
    http_req_failed: ['rate<0.05'],
  },
};

function makeRequest(method, url, body = null, maxRetries = 3) {
  let res;
  for (let i = 0; i < maxRetries; i++) {
    res = method === 'GET' 
      ? http.get(url) 
      : http[method.toLowerCase()](url, body, HEADERS);

    if (res.status !== 429) break;
    sleep(1);
  }

  if (res.status !== 202 && res.status !== 200 && res.status !== 404) {
    console.error(`[ERROR] ${method} ${url} → Status: ${res.status}, Body: ${res.body}`);
  }

  return res;
}


export default function () {
  let userId = Math.floor(Math.random() * 10000) + 1;

  let sleepRecordsRes = makeRequest('GET', `${BASE_URL}/users/${userId}/sleep_records`);
  check(sleepRecordsRes, { 
    'Sleep records: 200 or 404': (r) => r.status === 200 || r.status === 404 
  });

  if (sleepRecordsRes.status === 404) {
    let startSleepRes = makeRequest('POST', `${BASE_URL}/users/${userId}/sleep_records/start`);
    check(startSleepRes, { 'Start sleep: 202 Accepted': (r) => r.status === 202 });
  } else {
    let stopSleepRes = makeRequest('PATCH', `${BASE_URL}/users/${userId}/sleep_records/stop`);
    check(stopSleepRes, { 'Stop sleep: 202 Accepted': (r) => r.status === 202 });

    let startSleepRes = makeRequest('POST', `${BASE_URL}/users/${userId}/sleep_records/start`);
    check(startSleepRes, { 'Start sleep: 202 Accepted': (r) => r.status === 202 });
  }

  sleep(1 + Math.random() * 2);
}
