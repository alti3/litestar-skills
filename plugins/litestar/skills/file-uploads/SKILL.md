---
name: file-uploads
description: Implement secure file upload handling in Litestar with validation, size/type constraints, and storage pipeline integration.
---

# File Uploads

Use this skill when accepting multipart uploads.

## Workflow

1. Define accepted file size/type limits.
2. Parse and validate upload payloads explicitly.
3. Stream or persist files to configured storage.
4. Return normalized metadata responses.

## Checklist

- Enforce content-type and extension policies.
- Avoid loading large files fully into memory.
- Scan/validate files before downstream usage.

## Litestar References

- https://docs.litestar.dev/latest/usage/file-uploads.html
