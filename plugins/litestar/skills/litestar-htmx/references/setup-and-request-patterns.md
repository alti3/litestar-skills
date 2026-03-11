# Setup And Request Patterns

## Table of Contents

- Installing and enabling HTMX support
- Global HTMX setup with `HTMXPlugin`
- Local HTMX setup with `HTMXRequest`
- Branching on `request.htmx`

## Installing And Enabling HTMX Support

The usage docs note that the plugin can be installed via the `litestar[htmx]` extra.

Guidance:

- Use the extra when the project needs Litestar's HTMX integration primitives.
- Keep template engine setup separate; HTMX augments request and response behavior, it does not replace templating.

## Global HTMX Setup With `HTMXPlugin`

Use `HTMXPlugin()` when most routes should receive the HTMX-aware request class.

```python
from pathlib import Path

from litestar import Litestar
from litestar.contrib.jinja import JinjaTemplateEngine
from litestar.plugins.htmx import HTMXPlugin
from litestar.template.config import TemplateConfig


app = Litestar(
    route_handlers=[...],
    plugins=[HTMXPlugin()],
    template_config=TemplateConfig(
        directory=Path("templates"),
        engine=JinjaTemplateEngine,
    ),
)
```

Guidance:

- This is the simplest setup when HTMX is common across the app.
- The plugin defaults to setting the app request class to `HTMXRequest`.

### Keeping The Plugin But Not Forcing The Request Class Globally

The reference docs expose `HTMXConfig(set_request_class_globally: bool = True)`.

```python
from litestar import Litestar
from litestar.plugins.htmx import HTMXConfig, HTMXPlugin


app = Litestar(
    route_handlers=[...],
    plugins=[HTMXPlugin(config=HTMXConfig(set_request_class_globally=False))],
)
```

Use this when:

- the plugin should be available
- but only selected routers, controllers, or handlers should opt into `HTMXRequest`

## Local HTMX Setup With `HTMXRequest`

When HTMX applies only to part of the app, set the request class on the relevant layer.

```python
from pathlib import Path

from litestar import Litestar, get
from litestar.contrib.jinja import JinjaTemplateEngine
from litestar.plugins.htmx import HTMXRequest
from litestar.response import Template
from litestar.template.config import TemplateConfig


@get("/search", request_class=HTMXRequest)
def search_page(request: HTMXRequest) -> Template:
    if request.htmx:
        return Template(template_name="search/results.html.jinja2", context={"results": []})
    return Template(template_name="search/page.html.jinja2", context={"results": []})


app = Litestar(
    route_handlers=[search_page],
    template_config=TemplateConfig(
        directory=Path("templates"),
        engine=JinjaTemplateEngine,
    ),
)
```

Guidance:

- The docs allow `request_class` placement on app, router, controller, or route layers.
- Use the narrowest layer that matches the feature boundary.

## Branching On `request.htmx`

`HTMXRequest` exposes `request.htmx`, which is an `HTMXDetails` object. Its truthiness indicates whether the request came from an HTMX client.

```python
from litestar import get
from litestar.plugins.htmx import HTMXRequest, HTMXTemplate
from litestar.response import Template


@get("/contacts")
def contacts(request: HTMXRequest) -> Template:
    context = {"contacts": [{"name": "Ada"}]}
    if request.htmx:
        return HTMXTemplate(template_name="contacts/_table.html.jinja2", context=context)
    return Template(template_name="contacts/index.html.jinja2", context=context)
```

Guidance:

- Branch once and keep both code paths explicit.
- For HTMX flows, return only the markup that matches the target swap.
- For direct navigation, return a complete page with layout and surrounding structure.
