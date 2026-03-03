---
name: litestar-metrics
description: Add Litestar observability metrics via OpenTelemetry and Prometheus-compatible instrumentation, including request latency/error metrics and custom business counters. Use when implementing service-level monitoring and SLO visibility. Do not use for log formatting or exception contract design.
---

# Metrics

## Execution Workflow

1. Select telemetry backend/exporter strategy and endpoint model.
2. Instrument request-level metrics (count, duration, error rate) with stable labels.
3. Add domain-specific custom metrics at service boundaries.
4. Validate cardinality and collection overhead before production rollout.

## Implementation Rules

- Keep metric names and units consistent and documented.
- Avoid high-cardinality labels (user IDs, request IDs, raw payload values).
- Define clear ownership for metric lifecycle and deprecation.
- Correlate with logs/traces through shared dimensions.

## Example Pattern

```python
# Pseudocode pattern: register metrics exporter + emit domain counters.
from litestar import get

@get("/checkout")
async def checkout() -> dict[str, str]:
    # metrics.checkout_attempts.add(1)
    return {"status": "ok"}
```

## Validation Checklist

- Confirm telemetry endpoints export expected baseline metrics.
- Confirm custom metrics update correctly under concurrent load.
- Confirm dashboards and alerts map to real failure modes.
- Confirm instrumentation overhead remains acceptable.

## Cross-Skill Handoffs

- Use `litestar-logging` for event-level diagnostics.
- Use `litestar-debugging` and `litestar-testing` to validate instrumentation assumptions.

## Litestar References

- https://docs.litestar.dev/latest/usage/metrics/index.html
- https://docs.litestar.dev/latest/usage/metrics/0-basic-use.html
- https://docs.litestar.dev/latest/usage/metrics/1-custom-metrics.html
