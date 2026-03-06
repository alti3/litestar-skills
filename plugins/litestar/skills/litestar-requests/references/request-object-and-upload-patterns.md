# Request Object And Upload Patterns

## Table of Contents

- Accessing request metadata
- Auth, user, and state
- Raw body access
- Form data
- Multipart and uploads
- Upload processing guidance

## Accessing Request Metadata

Use `Request` when the handler needs metadata beyond normal typed parameters.

```python
from litestar import Request, get


@get("/inspect")
async def inspect_request(request: Request) -> dict[str, object]:
    return {
        "method": request.method,
        "path": request.url.path,
        "query": dict(request.query_params),
        "headers": {"x-request-id": request.headers.get("x-request-id")},
        "cookies": dict(request.cookies),
        "client": str(request.client),
    }
```

Guidance:

- Reach for `Request` only when the signature would otherwise become awkward or the data is genuinely request-contextual.
- Do not use raw metadata access as a substitute for normal typed handler parameters.

## Auth, User, And State

`Request` exposes auth-related and app-scoped context too.

```python
from litestar import Request, get


@get("/me")
async def me(request: Request) -> dict[str, object]:
    return {
        "user": getattr(request.user, "id", None),
        "auth": request.auth,
        "state": getattr(request.state, "tenant", None),
    }
```

Guidance:

- Use this only when the value is truly connection- or app-contextual.
- Prefer dependencies when the same derived context is reused across many handlers.

## Raw Body Access

Use request methods when the endpoint must work with the raw body directly.

```python
from litestar import Request, post


@post("/raw-json")
async def raw_json(request: Request) -> dict[str, object]:
    payload = await request.json()
    raw_body = await request.body()
    return {"keys": sorted(payload.keys()), "raw_size": len(raw_body)}
```

Guidance:

- Reach for raw body methods only when structured body parsing is not enough.
- Keep large-body handling bounded and intentional.

## Form Data

The request object can parse form data directly.

```python
from litestar import Request, post


@post("/form")
async def handle_form(request: Request) -> dict[str, str]:
    form = await request.form()
    return {"name": str(form.get("name", ""))}
```

Use this when:

- The form shape is small or dynamic.
- Modeling the form as a structured type is not worth the extra ceremony.

## Multipart And Uploads

Use `UploadFile` with explicit multipart encoding when the endpoint accepts files.

```python
from litestar import post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@post("/upload")
async def upload_file(
    data: UploadFile = Body(media_type=RequestEncodingType.MULTI_PART)
) -> dict[str, object]:
    content = await data.read()
    return {"filename": data.filename, "size": len(content)}
```

Guidance:

- Declare multipart explicitly.
- Validate filename, content expectations, and size before expensive processing.
- Avoid reading large files into memory unless the endpoint design truly permits it.

## Upload Processing Guidance

Practical rules for upload endpoints:

- Keep upload parsing close to the transport edge.
- Validate size and type assumptions early.
- Move storage, scanning, or persistence work into dedicated services.
- Use `litestar-file-uploads` when security and storage behavior become a primary concern.
