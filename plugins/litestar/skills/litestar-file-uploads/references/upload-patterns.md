# Upload Patterns

## Table of Contents

- Single file upload
- Sync vs async upload access
- Multipart model with mixed fields
- Multiple known files
- Files as a dictionary
- Files as a list

## Single File Upload

Use a single `UploadFile` when the whole body contract is one file.

```python
from typing import Annotated

from litestar import MediaType, post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@post(path="/", media_type=MediaType.TEXT)
async def handle_file_upload(
    data: Annotated[UploadFile, Body(media_type=RequestEncodingType.MULTI_PART)],
) -> str:
    content = await data.read()
    filename = data.filename
    return f"{filename},length: {len(content)}"
```

Guidance:

- This is the cleanest option when one uploaded file is the entire contract.
- Keep the response metadata minimal.

## Sync vs Async Upload Access

The docs show two access patterns:

- async handler: `await data.read()`
- sync handler: `data.file.read()`

```python
from typing import Annotated

from litestar import MediaType, post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@post(path="/", media_type=MediaType.TEXT, sync_to_thread=False)
def handle_file_upload(
    data: Annotated[UploadFile, Body(media_type=RequestEncodingType.MULTI_PART)],
) -> str:
    content = data.file.read()
    filename = data.filename
    return f"{filename},length: {len(content)}"
```

Guidance:

- Match file access to the handler style.
- Do not mix blocking file reads into async handlers.

## Multipart Model With Mixed Fields

Use a typed model when multipart includes both files and ordinary fields.

```python
from dataclasses import dataclass
from typing import Annotated

from litestar import post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@dataclass
class UserUpload:
    id: int
    name: str
    form_input_name: UploadFile


@post(path="/")
async def create_user(
    data: Annotated[UserUpload, Body(media_type=RequestEncodingType.MULTI_PART)],
) -> dict[str, str | int]:
    content = await data.form_input_name.read()
    return {
        "id": data.id,
        "name": data.name,
        "filename": data.form_input_name.filename or "",
        "size": len(content),
    }
```

Guidance:

- Prefer this over raw dictionaries when the multipart layout is known.
- Keep ordinary fields typed so validation stays near the transport edge.

## Multiple Known Files

When the form has several named files with known field names, use a model.

```python
from pydantic import BaseModel, ConfigDict
from typing import Annotated

from litestar import post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


class FormData(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    cv: UploadFile
    diploma: UploadFile


@post(path="/")
async def handle_file_upload(
    data: Annotated[FormData, Body(media_type=RequestEncodingType.MULTI_PART)],
) -> dict[str, str]:
    cv_content = await data.cv.read()
    diploma_content = await data.diploma.read()
    return {"cv": cv_content.decode(), "diploma": diploma_content.decode()}
```

## Files As A Dictionary

Use a dictionary only when you do not care about fixed field names or strict validation.

```python
from typing import Annotated

from litestar import post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@post(path="/")
async def handle_file_upload(
    data: Annotated[dict[str, UploadFile], Body(media_type=RequestEncodingType.MULTI_PART)],
) -> dict[str, int]:
    file_contents: dict[str, int] = {}
    for _, file in data.items():
        content = await file.read()
        file_contents[file.filename or ""] = len(content)
    return file_contents
```

## Files As A List

Use a list when the files are homogeneous and field names do not matter.

```python
from typing import Annotated, Any

from litestar import post
from litestar.datastructures import UploadFile
from litestar.enums import RequestEncodingType
from litestar.params import Body


@post(path="/")
async def handle_file_upload(
    data: Annotated[list[UploadFile], Body(media_type=RequestEncodingType.MULTI_PART)],
) -> dict[str, tuple[int, str | None, Any]]:
    result: dict[str, tuple[int, str | None, Any]] = {}
    for file in data:
        content = await file.read()
        result[file.filename or ""] = (len(content), file.content_type, file.headers)
    return result
```

Guidance:

- Use this only when the endpoint truly accepts a homogeneous bag of files.
- If the client contract depends on names, switch to a typed model instead.
