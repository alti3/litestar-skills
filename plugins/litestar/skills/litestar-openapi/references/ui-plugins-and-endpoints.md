# UI Plugins And Endpoints

## Table of Contents

- Bundled UI plugins
- Using render plugins
- Custom plugin paths and assets
- Endpoint behavior and backward-compatibility notes
- CDN and offline assets

## Bundled UI Plugins

The UI plugin docs describe bundled render plugins for:

- Scalar
- RapiDoc
- ReDoc
- Stoplight Elements
- Swagger UI
- YAML

Guidance:

- Pick one default UI per environment unless multiple UIs solve a real need.
- Keep plugin choice aligned with the audience using the docs.

## Using Render Plugins

The docs show UI plugins configured through `OpenAPIConfig.render_plugins`.

```python
from litestar import Litestar, get
from litestar.openapi.config import OpenAPIConfig
from litestar.openapi.plugins import ScalarRenderPlugin


@get("/", sync_to_thread=False)
def hello_world() -> dict[str, str]:
    return {"message": "Hello World"}


app = Litestar(
    route_handlers=[hello_world],
    openapi_config=OpenAPIConfig(
        title="Litestar Example",
        description="Example of Litestar with Scalar OpenAPI docs",
        version="0.0.1",
        render_plugins=[ScalarRenderPlugin()],
    ),
)
```

Guidance:

- Prefer explicit `render_plugins` over older root-site behavior when configuring docs UIs.
- Keep the docs path and plugin list intentional for each environment.

## Custom Plugin Paths And Assets

The UI plugin docs note common plugin options including:

- `path`
- `media_type`
- `favicon`
- `style`
- `version`
- `js_url`
- `css_url`

```python
from litestar.openapi.plugins import ScalarRenderPlugin


scalar_plugin = ScalarRenderPlugin(
    js_url="https://example.com/my-custom-scalar.js",
    css_url="https://example.com/my-custom-scalar.css",
    path="/scalar",
)
```

Use this when:

- The default docs path must change.
- Assets should come from a specific CDN or local hosting path.
- Docs UI branding or offline hosting matters.

## Endpoint Behavior And Backward-Compatibility Notes

The UI plugin docs note default docs endpoints and backward-compatibility behavior around `enabled_endpoints` and `root_schema_site`.

Practical guidance:

- Be explicit about which docs endpoints should exist.
- Prefer current render-plugin configuration rather than relying on deprecated compatibility paths.
- Verify `/schema` and the chosen UI endpoints behave as intended after configuration changes.

## CDN And Offline Assets

The docs state that `js_url` and `css_url` can point to CDN-hosted or locally served assets.

Guidance:

- Pin versions for reproducibility when using external assets.
- Use local or approved CDN assets when internet access is restricted.
- Test docs UIs in the real deployment environment, not only locally.
