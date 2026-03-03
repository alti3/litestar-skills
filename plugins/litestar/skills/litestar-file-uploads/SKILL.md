---
name: litestar-file-uploads
description: Handle Litestar multipart file uploads securely with typed UploadFile inputs, validation, streaming, and storage pipeline integration. Use when accepting single or multiple files in request bodies. Do not use for static asset serving or general file-response behavior.
---

# File Uploads

## Execution Workflow

1. Define accepted media types, size limits, and per-field upload expectations.
2. Type incoming multipart fields with `UploadFile` or typed containers.
3. Validate file metadata and content before persistence or downstream processing.
4. Stream/forward large files to durable storage without unbounded memory usage.
5. Return normalized metadata and operation status to clients.

## Implementation Rules

- Treat all uploaded files as untrusted input.
- Enforce explicit content-type and extension policy.
- Avoid reading full file contents into memory for large uploads.
- Integrate malware/content scanning where required by policy.

## Example Pattern

```python
from litestar import post
from litestar.datastructures import UploadFile

@post("/upload")
async def upload(file: UploadFile) -> dict[str, str]:
    return {"filename": file.filename or "unknown"}
```

## Validation Checklist

- Confirm invalid type/size uploads fail with deterministic client errors.
- Confirm multi-file forms map correctly to expected fields.
- Confirm temporary file and stream resources are cleaned up.
- Confirm upload metadata exposed in responses is minimal and safe.

## Cross-Skill Handoffs

- Use `litestar-requests` for broader body parsing and validation strategies.
- Use `litestar-static-files` and `litestar-responses` for download/serving concerns after upload.

## Litestar References

- https://docs.litestar.dev/latest/usage/requests.html#file-uploads
- https://docs.litestar.dev/latest/usage/requests.html
