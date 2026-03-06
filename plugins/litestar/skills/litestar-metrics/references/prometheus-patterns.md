# Prometheus Patterns

## Table of Contents

- Basic Prometheus exporter setup
- Custom controller path and format
- Labels, buckets, and exemplars
- Exclusions and path grouping
- When Prometheus fits best

## Basic Prometheus Exporter Setup

The metrics docs show Prometheus support via `litestar.plugins.prometheus`.

```python
from litestar import Litestar
from litestar.plugins.prometheus import PrometheusConfig, PrometheusController


prometheus_config = PrometheusConfig(group_path=True)

app = Litestar(
    route_handlers=[PrometheusController],
    middleware=[prometheus_config.middleware],
)
```

Guidance:

- The default metrics path is `/metrics`.
- Register the controller and middleware once at app scope.
- Use `group_path=True` when path parameters would otherwise create too many unique time series.

## Custom Controller Path And Format

The docs show that `PrometheusController` can be subclassed to change the path or enable openmetrics format.

```python
from litestar import Litestar
from litestar.plugins.prometheus import PrometheusConfig, PrometheusController


class CustomPrometheusController(PrometheusController):
    path = "/custom-path"
    openmetrics_format = True


prometheus_config = PrometheusConfig()

app = Litestar(
    route_handlers=[CustomPrometheusController],
    middleware=[prometheus_config.middleware],
)
```

Use this when:

- The scrape endpoint path must be customized.
- OpenMetrics output is required.

## Labels, Buckets, And Exemplars

The Prometheus docs show support for extra labels, histogram buckets, and exemplars.

```python
from typing import Any

from litestar import Litestar, Request
from litestar.plugins.prometheus import PrometheusConfig, PrometheusController


class CustomPrometheusController(PrometheusController):
    path = "/metrics"
    openmetrics_format = True


def custom_label_callable(request: Request[Any, Any, Any]) -> str:
    return "v2.0"


def custom_exemplar(request: Request[Any, Any, Any]) -> dict[str, str]:
    return {"trace_id": "1234"}


prometheus_config = PrometheusConfig(
    app_name="litestar-example",
    prefix="litestar",
    labels={"version_no": custom_label_callable, "location": "earth"},
    buckets=[0.1, 0.2, 0.3, 0.4, 0.5],
    exemplars=custom_exemplar,
)

app = Litestar(
    route_handlers=[CustomPrometheusController],
    middleware=[prometheus_config.middleware],
)
```

Guidance:

- Keep labels bounded and operator-meaningful.
- Use exemplars only when openmetrics format is enabled and your stack supports them.
- Tune buckets to real latency distributions, not arbitrary guesses.

## Exclusions And Path Grouping

The docs and reference show support for:

- `excluded_http_methods`
- `exclude`
- `exclude_opt_key`
- `exclude_unhandled_paths`
- `group_path`

```python
from litestar.plugins.prometheus import PrometheusConfig


prometheus_config = PrometheusConfig(
    excluded_http_methods=["POST"],
    exclude_unhandled_paths=True,
    group_path=True,
)
```

Guidance:

- Exclude noisy methods or routes only when the omission is intentional.
- Group paths early if route parameters would explode time-series count.
- Use route opt-outs sparingly and document them.

## When Prometheus Fits Best

Choose Prometheus when:

- Operators want a scrape endpoint exposed directly by the app.
- The monitoring stack already consumes Prometheus or OpenMetrics text.
- Per-route HTTP metrics are the main requirement and collector infrastructure is simple.
