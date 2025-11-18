# PyRon Webhook Service — Load Test Report

## Overview

This load test validates whether the webhook service can meet the performance requirements:

- **1000 requests per minute** (≈ 16.6 req/s)  
- **0% failures**  
- **Average latency < 300ms**  
- **p95 latency < 600ms**

The system was executed locally using the full stack:

- **FastAPI** (async)  
- **NGINX** (SSL termination)  
- **Redis + RQ Worker**  
- **MongoDB**  
- All orchestrated via **Docker Compose**


## Test Methodology

The test was executed with **k6**, using a steady load of 20 VUs for 60 seconds.

### Script summary:

```javascript
export const options = {
  stages: [
    { duration: "10s", target: 20 },
    { duration: "60s", target: 20 },
    { duration: "10s", target: 0 },
  ],
  insecureSkipTLSVerify: true,
};
```

Target endpoint:

```
POST https://localhost/webhook
```

Run command:

```
K6_INSECURE_SKIP_TLS_VERIFY=true k6 run load_test.js

```


## Hardware Used

The load test was executed on:

- **CPU:** AMD Ryzen 7 5800  
- **RAM:** 64 GB  
- **Storage:** NVMe SSD  
- **OS:** Linux (local development machine)

---

## Results Summary

| Metric | Result |
|--------|--------|
| **Total Requests** | **13,731** |
| **Avg Latency** | **1.91 ms** |
| **p95 Latency** | **3.24 ms** |
| **Errors** | **0.00%** |
| **Throughput** | **171.6 req/s** |
| **Equivalent req/min** | **10,296 req/min** |
| **Minimum Latency** | 0.79 ms |
| **Maximum Latency** | 8.85 ms |

## Visual Output (Screenshot)

A live screenshot from the execution is included to confirm the raw k6 output:

![k6 screenshot](./k6-output.png)

