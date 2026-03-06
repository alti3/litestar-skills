# Provider Patterns

## Table of Contents

- Layered scope
- Async providers
- Sync providers
- Callable class instances
- Request-derived keyword arguments
- Generator dependencies and cleanup
- Overrides
- `Provide` and caching
- Dependencies within dependencies
- App-scoped settings plus request-scoped service graph

## Layered Scope

Use lower scopes to override higher scopes with the same key.

```python
from litestar import Controller, Litestar, Router, get
from litestar.di import Provide


async def provide_settings() -> dict[str, str]:
    return {"env": "dev"}


async def provide_feature_flags() -> dict[str, bool]:
    return {"beta": True}


async def provide_audit_actor() -> str:
    return "system"


async def provide_local_actor() -> str:
    return "route-local"


class AdminController(Controller):
    path = "/admin"
    dependencies = {"audit_actor": Provide(provide_audit_actor)}

    @get("/dashboard", dependencies={"audit_actor": Provide(provide_local_actor)})
    async def dashboard(
        self,
        settings: dict[str, str],
        feature_flags: dict[str, bool],
        audit_actor: str,
    ) -> dict[str, object]:
        return {
            "settings": settings,
            "feature_flags": feature_flags,
            "audit_actor": audit_actor,
        }


admin_router = Router(
    path="/v1",
    route_handlers=[AdminController],
    dependencies={"feature_flags": Provide(provide_feature_flags)},
)

app = Litestar(
    route_handlers=[admin_router],
    dependencies={"settings": Provide(provide_settings)},
)
```

Guidance:

- Reuse keys only when you intentionally want override behavior.
- Do not declare a dependency at app scope if only one route needs it.
- Treat overrides as part of the contract; name keys so replacement is obvious.

## Async Providers

Use async providers for I/O-bound work that is naturally asynchronous.

```python
from litestar.di import Provide


async def provide_user_service() -> "UserService":
    return UserService()


dependencies = {"user_service": Provide(provide_user_service)}
```

## Sync Providers

Use sync providers only when they are truly synchronous. If they block on I/O or are CPU-heavy, set `sync_to_thread=True`. If they are cheap and non-blocking, set `sync_to_thread=False` explicitly.

```python
from litestar.di import Provide


def provide_build_info() -> dict[str, str]:
    return {"version": "1.0.0"}


dependencies = {
    "build_info": Provide(provide_build_info, sync_to_thread=False),
}
```

## Callable Class Instances

Use callable objects when dependency construction needs configuration but invocation should still be DI-managed.

```python
from dataclasses import dataclass

from litestar.di import Provide


@dataclass
class Settings:
    region: str


class TenantResolver:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    async def __call__(self, tenant_id: str) -> str:
        return f"{self.settings.region}:{tenant_id}"


settings = Settings(region="eu")
dependencies = {"tenant": Provide(TenantResolver(settings))}
```

## Request-Derived Keyword Arguments

Providers can receive the same injected keyword arguments that handlers can receive.

```python
from uuid import UUID

from litestar import Controller, get
from litestar.di import Provide


class User:
    def __init__(self, user_id: UUID, name: str) -> None:
        self.id = user_id
        self.name = name


async def provide_user(user_id: UUID) -> User:
    return User(user_id=user_id, name="Ada")


class UserController(Controller):
    path = "/users"
    dependencies = {"user": Provide(provide_user)}

    @get("/{user_id:uuid}")
    async def get_user(self, user: User) -> dict[str, str]:
        return {"id": str(user.id), "name": user.name}
```

Guidance:

- Prefer deriving domain objects once in a provider instead of repeating lookup logic in handlers.
- Keep provider argument names aligned with route parameter names.
- Treat request-derived providers as translation boundaries from transport inputs to domain types.

## Generator Dependencies and Cleanup

Use generator dependencies when setup and cleanup belong to the same logical resource.

```python
from collections.abc import Generator

from litestar import Litestar, get
from litestar.di import Provide


STATE = {"connection": "closed", "result": None}


def provide_connection() -> Generator[str, None, None]:
    try:
        STATE["connection"] = "open"
        yield "conn"
        STATE["result"] = "ok"
    except ValueError:
        STATE["result"] = "error"
    finally:
        STATE["connection"] = "closed"


@get("/{name:str}", dependencies={"conn": Provide(provide_connection)})
def handler(name: str, conn: str) -> dict[str, str]:
    if name != "ok":
        raise ValueError("boom")
    return {"name": name, "conn": conn}


app = Litestar(route_handlers=[handler])
```

Rules from the Litestar docs:

- Cleanup runs after the handler returns and before the HTTP response is sent.
- If the handler raises, that exception is thrown back into the generator at the `yield` point.
- Wrap generator dependencies in `try`/`finally` even if custom exception handling is not needed.
- Do not re-raise exceptions from inside the dependency just to preserve framework handling.
- Cleanup exceptions are collected and re-raised after all dependency cleanup has run.

## Overrides

Overrides are key-based. A lower-scoped dependency with the same key replaces the higher-scoped one.

```python
from litestar import Controller, get
from litestar.di import Provide


def provide_controller_mode() -> str:
    return "controller"


def provide_handler_mode() -> str:
    return "handler"


class ExampleController(Controller):
    path = "/example"
    dependencies = {"mode": Provide(provide_controller_mode)}

    @get("/default")
    def default(self, mode: str) -> dict[str, str]:
        return {"mode": mode}

    @get("/override", dependencies={"mode": Provide(provide_handler_mode)})
    def override(self, mode: str) -> dict[str, str]:
        return {"mode": mode}
```

## `Provide` and Caching

Use `Provide.use_cache` only when reusing the same computed value within the request is correct.

```python
from litestar import Litestar, get
from litestar.di import Provide


def provide_request_context() -> dict[str, str]:
    return {"trace_id": "abc123"}


@get("/context")
def read_context(context: dict[str, str]) -> dict[str, str]:
    return context


app = Litestar(
    route_handlers=[read_context],
    dependencies={"context": Provide(provide_request_context, use_cache=True)},
)
```

Caching guidance:

- `use_cache=True` memoizes the first return value used for that dependency.
- The cache is not argument-sensitive.
- Treat the cached value as request-scoped shared state for the dependency graph.
- Do not cache mutable objects if later code may mutate them unexpectedly.

## Dependencies Within Dependencies

Providers can depend on other providers.

```python
from litestar import Litestar, get
from litestar.di import Provide


class Settings:
    debug = True


def provide_settings() -> Settings:
    return Settings()


def provide_repository(settings: Settings) -> str:
    return "repo-debug" if settings.debug else "repo-prod"


def provide_service(repository: str) -> str:
    return f"service({repository})"


@get("/service")
def read_service(service: str) -> dict[str, str]:
    return {"service": service}


app = Litestar(
    route_handlers=[read_service],
    dependencies={
        "settings": Provide(provide_settings),
        "repository": Provide(provide_repository),
        "service": Provide(provide_service),
    },
)
```

Guidance:

- Keep dependency graphs shallow enough to reason about quickly.
- Compose stable layers: settings -> client/session -> repository -> service.
- Do not inject transport-only values deep into domain services unless that coupling is deliberate.
- Remember that override rules still apply inside nested dependency graphs.

## App-Scoped Settings Plus Request-Scoped Service Graph

```python
from collections.abc import AsyncGenerator
from dataclasses import dataclass

from litestar import Litestar, get
from litestar.di import Provide


@dataclass(frozen=True)
class Settings:
    dsn: str


class Session:
    async def close(self) -> None:
        pass


class UserRepository:
    def __init__(self, session: Session) -> None:
        self.session = session


class UserService:
    def __init__(self, repo: UserRepository) -> None:
        self.repo = repo


async def provide_settings() -> Settings:
    return Settings(dsn="sqlite+aiosqlite:///app.sqlite")


async def provide_session(settings: Settings) -> AsyncGenerator[Session, None]:
    session = Session()
    try:
        yield session
    finally:
        await session.close()


def provide_user_repo(session: Session) -> UserRepository:
    return UserRepository(session=session)


def provide_user_service(user_repo: UserRepository) -> UserService:
    return UserService(repo=user_repo)


@get("/users")
async def list_users(user_service: UserService) -> dict[str, str]:
    return {"service": user_service.__class__.__name__}


app = Litestar(
    route_handlers=[list_users],
    dependencies={
        "settings": Provide(provide_settings),
        "session": Provide(provide_session),
        "user_repo": Provide(provide_user_repo),
        "user_service": Provide(provide_user_service),
    },
)
```

Why this pattern works:

- Settings are pure and globally reusable.
- Session lifecycle is explicit and request-bounded.
- Repository and service wiring stay transport-agnostic.
- Handlers receive domain services instead of constructing infrastructure.
