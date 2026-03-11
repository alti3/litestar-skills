# Router Basics And Naming

## Table of Contents

- Basic static router setup
- Directory resolution
- Sending files as attachments
- Naming routers for URL reversal

## Basic Static Router Setup

The current Litestar docs center static serving around `create_static_files_router()`.

```python
from pathlib import Path

from litestar import Litestar
from litestar.static_files import create_static_files_router

ASSETS_DIR = Path("assets")


def on_startup() -> None:
    ASSETS_DIR.mkdir(exist_ok=True)
    ASSETS_DIR.joinpath("app.css").write_text("body { color: black; }")


app = Litestar(
    route_handlers=[
        create_static_files_router(path="/static", directories=["assets"]),
    ],
    on_startup=[on_startup],
)
```

Guidance:

- Use `create_static_files_router()` as the default pattern for current Litestar work.
- Keep the mount path explicit and stable.
- Keep directories narrow and purpose-specific.

## Directory Resolution

The usage docs note that directories are interpreted relative to the working directory from which the application starts.

Practical implications:

- `directories=["assets"]` depends on the process working directory.
- Use `Path(...)` or absolute paths when startup cwd may differ across environments.
- Keep deployment and local dev aligned so asset lookup does not drift.

Safer explicit-path pattern:

```python
from pathlib import Path

from litestar import Litestar
from litestar.static_files import create_static_files_router

BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "assets"

app = Litestar(
    route_handlers=[
        create_static_files_router(path="/static", directories=[STATIC_DIR]),
    ]
)
```

## Sending Files As Attachments

By default, static files are served inline. Set `send_as_attachment=True` when the browser should treat them as downloads.

```python
from litestar import Litestar
from litestar.static_files import create_static_files_router


app = Litestar(
    route_handlers=[
        create_static_files_router(
            path="/downloads",
            directories=["release-artifacts"],
            send_as_attachment=True,
            name="downloads",
        )
    ]
)
```

Use this when:

- artifacts should download rather than render in-browser
- the mounted directory is a distribution channel rather than a page asset folder

Guidance:

- Keep download mounts separate from normal page assets.
- If downloads need auth or per-request business rules, a custom handler may be more appropriate than a plain static mount.

## Naming Routers For URL Reversal

`create_static_files_router()` accepts `name=`. The docs note that the default is `static`.

```python
from litestar import Litestar
from litestar.static_files import create_static_files_router


app = Litestar(
    route_handlers=[
        create_static_files_router(
            path="/assets",
            directories=["frontend-assets"],
            name="frontend-assets",
        )
    ]
)

asset_path = app.route_reverse(name="frontend-assets", file_path="/app.js")
```

Guidance:

- Set `name=` explicitly when there is more than one static router.
- Use route reversal in Python and `url_for` / `url_for_static_asset` from templates instead of hardcoding asset paths.
