# Parameter And Body Patterns

## Table of Contents

- Path parameters
- Query parameters
- Header and cookie parameters
- Structured body data
- Explicit body metadata
- Repeated or list-like query parameters

## Path Parameters

Type path parameters directly in the handler signature.

```python
from uuid import UUID

from litestar import get


@get("/users/{user_id:uuid}")
def get_user(user_id: UUID) -> dict[str, str]:
    return {"user_id": str(user_id)}
```

Guidance:

- Keep the route path converter and Python type aligned.
- Prefer strict domain types such as `UUID` instead of loose `str` when the contract is known.

## Query Parameters

Use `Parameter(...)` when query aliases or validation constraints matter.

```python
from litestar import get
from litestar.params import Parameter


@get("/search")
def search(
    page: int = Parameter(query="page", ge=1, default=1),
    page_size: int = Parameter(query="pageSize", ge=1, le=100, default=25),
) -> dict[str, int]:
    return {"page": page, "page_size": page_size}
```

Guidance:

- Use aliases only when the wire contract requires a different client-facing name.
- Keep numeric bounds and other validation close to the parameter.

## Header And Cookie Parameters

Headers and cookies can be bound directly with `Parameter(...)`.

```python
from litestar import get
from litestar.params import Parameter


@get("/session")
def read_session(
    request_id: str | None = Parameter(header="x-request-id", default=None),
    session_id: str | None = Parameter(cookie="session_id", default=None),
) -> dict[str, str | None]:
    return {"request_id": request_id, "session_id": session_id}
```

Guidance:

- Keep security-sensitive cookies and headers typed and explicit.
- Prefer handler parameters over manual `request.headers[...]` access when all you need is one value.

## Structured Body Data

Use a structured `data` parameter when the request body has a known schema.

```python
from dataclasses import dataclass

from litestar import post


@dataclass
class CreateUserDTO:
    email: str
    display_name: str


@post("/users")
async def create_user(data: CreateUserDTO) -> CreateUserDTO:
    return data
```

Guidance:

- Prefer structured body types over loose dicts.
- Keep transport models small and explicit.

## Explicit Body Metadata

Use `Body(...)` when the body needs extra metadata or a non-default encoding declaration.

```python
from dataclasses import dataclass

from litestar import post
from litestar.params import Body


@dataclass
class CreateUserDTO:
    email: str
    display_name: str


@post("/users")
async def create_user(data: CreateUserDTO = Body(title="CreateUserRequest")) -> CreateUserDTO:
    return data
```

Use this when:

- OpenAPI body metadata should be explicit.
- Encoding or documentation details need to be declared at the parameter.

## Repeated Or List-Like Query Parameters

Repeated query parameters can be expressed as collection types.

```python
from litestar import get
from litestar.params import Parameter


@get("/filter")
def filter_items(tags: list[str] = Parameter(query="tag", default=[])) -> dict[str, list[str]]:
    return {"tags": tags}
```

Guidance:

- Use repeated query parameters only when the wire contract is truly list-shaped.
- Keep naming consistent between the client-facing key and the model type.
