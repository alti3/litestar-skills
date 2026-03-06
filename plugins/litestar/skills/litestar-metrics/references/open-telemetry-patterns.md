# OpenTelemetry Patterns

## Table of Contents

- Basic OpenTelemetry setup
- Provider and exporter expectations
- Configuration guidance
- When OpenTelemetry fits best

## Basic OpenTelemetry Setup

The metrics docs show Litestar OpenTelemetry support via `OpenTelemetryConfig` and `OpenTelemetryPlugin`.

```python
from litestar import Litestar
from litestar.contrib.opentelemetry import OpenTelemetryConfig, OpenTelemetryPlugin


open_telemetry_config = OpenTelemetryConfig()

app = Litestar(plugins=[OpenTelemetryPlugin(open_telemetry_config)])
```

Guidance:

- Register the plugin once at app construction.
- Keep OTel setup centralized so provider and exporter behavior remain auditable.

## Provider And Exporter Expectations

The docs note that the basic setup works if a global `tracer_provider` and or `metric_provider` plus exporter are configured.

Practical guidance:

- Treat provider and exporter configuration as application infrastructure, not route-level logic.
- Make exporter ownership explicit in deployment or app setup.
- Validate that metrics really leave the process before assuming dashboards will populate.

## Configuration Guidance

The OpenTelemetry docs note that `OpenTelemetryConfig` can be customized with provider-related configuration.

Guidance:

- Keep custom OTel config close to app creation.
- Prefer documented config fields over ad hoc middleware wrapping.
- If traces and metrics are both enabled, keep naming and resource identity aligned.

## When OpenTelemetry Fits Best

Choose OpenTelemetry when:

- The service already uses an OTel collector or shared observability pipeline.
- Operators want metrics and traces to share ecosystem conventions.
- Exporter configuration is already part of the platform.

Avoid forcing OTel if the requirement is simply a directly scraped metrics endpoint with minimal infrastructure.
