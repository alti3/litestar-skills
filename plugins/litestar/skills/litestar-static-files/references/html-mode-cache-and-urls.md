# HTML Mode, Cache, And URLs

## Table of Contents

- HTML mode
- Cache behavior and `cache_control`
- Passing router options
- Building static URLs in app code and templates

## HTML Mode

The usage docs describe `html_mode=True` as a static-site mode:

- `/` serves `index.html`
- missing files attempt to serve `404.html`

```python
from pathlib import Path

from litestar import Litestar
from litestar.static_files import create_static_files_router

HTML_DIR = Path("html")


def on_startup() -> None:
    HTML_DIR.mkdir(exist_ok=True)
    HTML_DIR.joinpath("index.html").write_text("<h1>Home</h1>")
    HTML_DIR.joinpath("404.html").write_text("<h1>Not found</h1>")


app = Litestar(
    route_handlers=[
        create_static_files_router(
            path="/",
            directories=["html"],
            html_mode=True,
            name="site",
        )
    ],
    on_startup=[on_startup],
)
```

Guidance:

- Use this for static landing pages, docs mirrors, or simple static sites.
- Do not use HTML mode as a replacement for templated server-rendered pages with dynamic context.
- Be intentional when mounting at `/`, because it changes root-route ownership.

## Cache Behavior And `cache_control`

The reference docs expose `cache_control=` on `create_static_files_router()`.

```python
from litestar import Litestar
from litestar.datastructures import CacheControlHeader
from litestar.static_files import create_static_files_router


app = Litestar(
    route_handlers=[
        create_static_files_router(
            path="/assets",
            directories=["dist"],
            cache_control=CacheControlHeader(public=True, max_age=31536000, immutable=True),
        )
    ]
)
```

Guidance:

- Apply long-lived cache headers only to hashed or immutable asset names.
- Keep cache settings conservative for mutable filenames such as `/assets/app.css` without content hashing.
- Align Litestar cache headers with CDN behavior so browsers and edges see the same freshness model.

## Passing Router Options

The usage and reference docs note that normal `Router` options can be passed directly to `create_static_files_router()`.

Common examples:

- `include_in_schema`
- `tags`
- `guards`
- `middleware`
- `before_request`
- `after_request`
- `exception_handlers`
- `opt`
- `security`
- `router_class`

```python
from litestar import Litestar
from litestar.static_files import create_static_files_router


app = Litestar(
    route_handlers=[
        create_static_files_router(
            path="/private-assets",
            directories=["private-assets"],
            include_in_schema=False,
            tags=["static"],
            opt={"audited": True},
        )
    ]
)
```

Guidance:

- Keep `include_in_schema=False` unless documentation of static routes is deliberate.
- Use guards or middleware when asset access truly needs policy enforcement.
- Keep router metadata sparse; static routes rarely need much schema surface.

## Building Static URLs In App Code And Templates

The docs show `route_reverse()` with the `file_path` parameter.

```python
from litestar import Litestar
from litestar.static_files import create_static_files_router


app = Litestar(
    route_handlers=[
        create_static_files_router(path="/static", directories=["assets"], name="static")
    ]
)

logo_path = app.route_reverse(name="static", file_path="/logo.svg")
```

In templates, prefer Litestar URL helpers rather than hardcoded literal paths.

Guidance:

- The router name must match the `name=` passed to `create_static_files_router()`.
- Standardize route names early so templates and backend code do not drift.
- Keep static path generation centralized when multiple mounts exist.
