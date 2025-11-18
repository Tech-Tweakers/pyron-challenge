import http from "k6/http";
import { sleep } from "k6";

export let options = {
  stages: [
    { duration: "10s", target: 20 },  // warm up
    { duration: "60s", target: 20 },  // 20 VUs ~ 1000 req/min
    { duration: "10s", target: 0 },   // ramp down
  ]
};

export default function () {
  const url = "https://localhost/webhook";

  const payload = JSON.stringify({
    id: Math.random().toString(36).slice(2),
    value: Math.random()
  });

  const params = {
    headers: { "Content-Type": "application/json" }
  };

  http.post(url, payload, params);

  sleep(0.1); // ~ 10 req/s por VU
}

