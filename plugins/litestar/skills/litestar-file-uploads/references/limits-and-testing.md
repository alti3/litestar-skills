# Limits And Testing

## Table of Contents

- Request body limits
- `UploadFile` internals
- Safe processing guidance
- Multipart test pattern
- Size-limit test guidance

## Request Body Limits

The requests docs state that `request_max_body_size` defaults to 10MB and applies across Litestar layers.

Guidance:

- Lower the limit on sensitive upload endpoints unless large files are intentional.
- Set it to `None` only when an external reverse proxy already enforces a strict limit.
- Remember that `None` is dangerous because it exposes the route to memory exhaustion if no outside limit exists.

```python
from typing import Annotated

from litestar import post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@post(path="/upload", request_max_body_size=2 * 1024 * 1024)
async def upload(
    data: Annotated[UploadFile, Body(media_type=RequestEncodingType.MULTI_PART)],
) -> dict[str, str]:
    return {"filename": data.filename or ""}
```

## `UploadFile` Internals

The docs note that `UploadFile` wraps `SpooledTemporaryFile` so it can be used asynchronously.

Practical implications:

- Async handlers should use the async interface.
- Sync handlers can read from `data.file` directly.
- Temporary-file behavior is framework-managed, but route logic should still avoid leaking handles or paths.

## Safe Processing Guidance

Use these defaults for upload endpoints:

- Validate content type and filename before expensive processing.
- Stream or chunk work for larger files.
- Move scanning, storage, and persistence into dedicated services.
- Return only minimal metadata such as accepted filename, size, or operation ID.

## Multipart Test Pattern

The requests docs include `TestClient` patterns for multipart forms.

```python
from io import BytesIO

from litestar.testing import TestClient


def test_request_data() -> None:
    with TestClient(app=app) as client:
        response = client.post(
            "/",
            files={"form_input_name": ("filename", BytesIO(b"file content"))},
            data={"id": 1, "name": "John"},
        )
        assert response.status_code == 201
```

Guidance:

- Keep file fixtures small unless you are explicitly testing size limits.
- Assert both the HTTP contract and the parsed metadata.

## Size-Limit Test Guidance

For endpoints with custom `request_max_body_size` values:

- Add at least one negative test that exceeds the configured limit.
- Assert the route fails with the expected client error instead of hanging or exhausting memory.
- Keep this in `litestar-testing` when test harness design is the main concern.
