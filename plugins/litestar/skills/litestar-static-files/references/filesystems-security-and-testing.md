# File Systems, Security, And Testing

## Table of Contents

- Custom and remote file systems
- Symlink handling
- Security boundaries
- Testing static routes

## Custom And Remote File Systems

The docs allow `file_system=` to use Litestar file-system integrations or compatible `fsspec` file systems.

```python
from fsspec.implementations.ftp import FTPFileSystem

from litestar import Litestar
from litestar.static_files import create_static_files_router


app = Litestar(
    route_handlers=[
        create_static_files_router(
            path="/static",
            directories=["assets"],
            file_system=FTPFileSystem(host="127.0.0.1"),
        )
    ]
)
```

Guidance:

- Use a custom file system only when local disk is not the right source of truth.
- Treat remote/static storage latency and availability as part of the route contract.
- Keep directory roots narrow even on remote file systems.

## Symlink Handling

Inference from the latest usage and reference docs:

- Recent docs expose a symlink-escape control on `create_static_files_router()`.
- The naming differs across versions and doc surfaces:
  `resolve_symlinks` appears in Litestar 2 reference docs, while newer docs describe `allow_symlinks_outside_directory`.

Practical guidance that remains stable:

- Keep the default restrictive behavior.
- Do not allow symlink traversal outside configured directories unless the environment is tightly controlled.
- Treat symlink relaxation as a security review item, not a convenience flag.

## Security Boundaries

Static serving is safe only when the source directories are safe.

Rules of thumb:

- Keep trusted build assets separate from user-generated content.
- Avoid broad directories that might contain secrets, config files, or source code.
- Prefer explicit asset directories such as `dist/`, `public/`, or `assets/`.
- If files need authorization, signed URLs, audit logging, or domain-specific access checks, use custom handlers instead of a plain static router.

## Testing Static Routes

A simple test should prove both successful delivery and missing-file behavior.

```python
from pathlib import Path

from litestar import Litestar
from litestar.static_files import create_static_files_router
from litestar.testing import TestClient


def build_app(tmp_path: Path) -> Litestar:
    asset_dir = tmp_path / "assets"
    asset_dir.mkdir()
    asset_dir.joinpath("app.css").write_text("body { color: black; }")
    return Litestar(
        route_handlers=[
            create_static_files_router(path="/static", directories=[asset_dir]),
        ]
    )


def test_static_file_serving(tmp_path: Path) -> None:
    with TestClient(app=build_app(tmp_path)) as client:
        ok = client.get("/static/app.css")
        missing = client.get("/static/missing.css")

        assert ok.status_code == 200
        assert "body" in ok.text
        assert missing.status_code == 404
```

Also test when relevant:

- `Content-Disposition` for attachment mounts
- `index.html` and `404.html` behavior in HTML mode
- cache headers when `cache_control=` is configured
- route reversal or template URL helper output when multiple static routers exist

Guidance:

- Use temp directories so static-route tests stay deterministic.
- Cover one missing-file path even in simple apps; static `404` behavior is part of the contract.
