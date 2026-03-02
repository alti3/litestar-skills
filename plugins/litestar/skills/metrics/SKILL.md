---
name: metrics
description: Instrument Litestar applications with OpenTelemetry and Prometheus-compatible metrics for request latency, throughput, and error monitoring.
---

# Metrics

Use this skill when instrumenting APIs for observability and SLO tracking.

## Workflow

1. Choose telemetry path: OpenTelemetry exporter stack and/or Prometheus scraping.
2. Add instrumentation middleware/plugin at app boot.
3. Emit domain metrics from service boundaries, not only transport layer.
4. Validate cardinality and label strategy before production rollout.

## Instrumentation Checklist

- Track request count, duration, and error rate by route/method/status.
- Avoid high-cardinality labels (raw user IDs, request IDs as metric labels).
- Correlate metrics with logs/traces using shared dimensions.
- Add health/readiness checks for telemetry pipelines.

## Litestar References

- https://docs.litestar.dev/latest/usage/metrics/index.html
- https://docs.litestar.dev/latest/usage/metrics/0-basic-use.html
- https://docs.litestar.dev/latest/usage/metrics/1-custom-metrics.html
