# Listener Patterns

## Table of Contents

- Basic listener registration
- Emitting from a route handler
- Listening to multiple events
- Using multiple listeners for one event
- Passing arguments to listeners safely
- Service-layer event emission

## Basic Listener Registration

Litestar's event bus uses `@listener(...)` decorators plus app-level registration in `listeners=[...]`.

```python
from litestar import Litestar
from litestar.events import listener


@listener("user_created")
async def send_welcome_email_handler(email: str) -> None:
    await send_welcome_mail(email)


app = Litestar(route_handlers=[...], listeners=[send_welcome_email_handler])
```

Guidance:

- Register listeners on the app, not implicitly through import side effects.
- Keep event IDs stable and descriptive.

## Emitting from a Route Handler

The usage docs show event emission through `request.app.emit(...)`.

```python
from dataclasses import dataclass

from litestar import Litestar, Request, post
from litestar.events import listener


@listener("user_created")
async def send_welcome_email_handler(email: str) -> None:
    await send_welcome_mail(email)


@dataclass
class CreateUserDTO:
    first_name: str
    last_name: str
    email: str


@post("/users")
async def create_user_handler(data: CreateUserDTO, request: Request) -> None:
    await user_repository.insert(data)
    request.app.emit("user_created", email=data.email)


app = Litestar(route_handlers=[create_user_handler], listeners=[send_welcome_email_handler])
```

The docs describe this pattern as a way to perform async operations without blocking the response cycle.

## Listening to Multiple Events

A single listener can subscribe to multiple event IDs.

```python
from litestar.events import listener


@listener("user_created", "password_changed")
async def send_email_handler(email: str, message: str) -> None:
    await send_email(email, message)
```

Use this when:

- The listener behavior is genuinely shared.
- The events have the same argument contract.
- Maintaining one listener is simpler than keeping duplicates in sync.

## Using Multiple Listeners For One Event

Multiple listeners can react to the same event independently.

```python
from dataclasses import dataclass

from litestar import Litestar, Request, post
from litestar.events import listener


@listener("user_deleted")
async def send_farewell_email_handler(email: str, **kwargs: object) -> None:
    await send_farewell_email(email)


@listener("user_deleted")
async def notify_customer_support(reason: str, **kwargs: object) -> None:
    await client.post("some-url", reason)


@dataclass
class DeleteUserDTO:
    email: str
    reason: str


@post("/users")
async def delete_user_handler(data: DeleteUserDTO, request: Request) -> None:
    await user_repository.delete({"email": data.email})
    request.app.emit("user_deleted", email=data.email, reason="deleted")


app = Litestar(
    route_handlers=[delete_user_handler],
    listeners=[send_farewell_email_handler, notify_customer_support],
)
```

Guidance:

- Keep each listener independently understandable and testable.
- Avoid coupling listeners to each other through shared mutable state.

## Passing Arguments To Listeners Safely

The docs emphasize that `emit` has the signature `emit(event_id: str, *args: Any, **kwargs: Any) -> None`. Every listener attached to that event receives the same args and kwargs.

This is the main contract hazard.

```python
from litestar.events import listener


@listener("user_deleted")
async def send_farewell_email_handler(email: str, **kwargs: object) -> None:
    await send_farewell_email(email)


@listener("user_deleted")
async def notify_customer_support(reason: str, **kwargs: object) -> None:
    await client.post("some-url", reason)
```

Guidance:

- Prefer keyword arguments for readability and forwards compatibility.
- Add `**kwargs` when listeners only consume part of a shared event payload.
- Do not emit one shape for an event in one place and a different shape elsewhere.
- If contracts are drifting, split the event ID rather than overloading one event.

## Service-Layer Event Emission

Handlers do not need to own event emission directly. It can be delegated to a service that receives an app reference or emitter-capable dependency.

```python
from dataclasses import dataclass
from typing import Protocol

from litestar import Request, post


@dataclass
class CreateUserDTO:
    email: str


class EmitsEvents(Protocol):
    def emit(self, event_id: str, *args: object, **kwargs: object) -> None: ...


@dataclass
class AccountService:
    async def create_user(self, data: CreateUserDTO, app: EmitsEvents) -> None:
        await user_repository.insert(data)
        app.emit("user_created", email=data.email)


@post("/users")
async def create_user_handler(
    data: CreateUserDTO,
    request: Request,
    account_service: AccountService,
) -> None:
    await account_service.create_user(data=data, app=request.app)
```

Guidance:

- Keep the event close to the domain action that authoritatively triggers it.
- Do not emit before the state change has succeeded.
