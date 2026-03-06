# Template Callables And Custom Engines

## Table of Contents

- Built-in callables
- Registering custom template callables
- MiniJinja callable context
- Implementing a custom template engine

## Built-In Callables

Litestar provides template callables for common presentation needs:

- `url_for` for route reversal.
- `url_for_static_asset` for static asset URLs.
- `csrf_token` for embedding the CSRF token outside the normal hidden input helper.

Jinja-style examples:

```html
<a href="{{ url_for('home') }}">Home</a>
<link rel="stylesheet" href="{{ url_for_static_asset('css', 'app.css') }}">
<meta name="csrf-token" content="{{ csrf_token() }}">
```

Guidance:

- Use helper callables instead of hardcoded route paths.
- Keep asset linking aligned with the app's static-files configuration.
- Reserve `csrf_token()` for non-form or custom-token-placement cases.

## Registering Custom Template Callables

Register custom callables through `engine_callback=` so they are added once when the engine is created.

```python
from pathlib import Path
from typing import Any

from litestar import Litestar, get
from litestar.contrib.jinja import JinjaTemplateEngine
from litestar.response import Template
from litestar.template.config import TemplateConfig


def section_title(ctx: dict[str, Any]) -> str:
    return ctx.get("title", "Untitled")


def configure_engine(engine: JinjaTemplateEngine) -> None:
    engine.register_template_callable(key="section_title", template_callable=section_title)


@get("/", sync_to_thread=False)
def index() -> Template:
    return Template(template_name="index.html.jinja2", context={"title": "Overview"})


app = Litestar(
    route_handlers=[index],
    template_config=TemplateConfig(
        directory=Path("templates"),
        engine=JinjaTemplateEngine,
        engine_callback=configure_engine,
    ),
)
```

Template usage:

```html
<h1>{{ section_title() }}</h1>
```

Guidance:

- Keep template callables deterministic and side-effect free.
- Have callables depend on the passed context, not hidden global state.
- Register them once through configuration, not per request.

## MiniJinja Callable Context

The docs use a different callable context type for MiniJinja: `StateProtocol`.

```python
from litestar.contrib.minijinja import StateProtocol


def section_title(ctx: StateProtocol) -> str:
    return ctx.lookup("title") or "Untitled"
```

Guidance:

- Match the callable signature to the engine the project uses.
- When porting a Jinja or Mako example to MiniJinja, adjust context access accordingly.

## Implementing A Custom Template Engine

Use a custom engine only when the built-in engines do not fit. The usage guide shows a minimal protocol shape, and the current reference API defines the fuller contract used by Litestar.

```python
from collections.abc import Callable, Mapping
from pathlib import Path
from typing import Any


class CustomTemplateEngine:
    def __init__(self, directory: Path | list[Path] | None, engine_instance: Any | None = None) -> None:
        self.directory = directory
        if engine_instance is None:
            raise ValueError("Provide an initialized engine instance or add engine construction here.")
        self.engine = engine_instance

    def get_template(self, template_name: str) -> Any:
        return self.engine.load(template_name)

    def render_string(self, template_string: str, context: Mapping[str, Any]) -> str:
        return self.engine.render_inline(template_string, context)

    def register_template_callable(
        self, key: str, template_callable: Callable[[Mapping[str, Any]], Any]
    ) -> None:
        self.engine.register_callable(key, template_callable)
```

Guidance:

- Follow the current reference API when implementing custom engines, especially if inline string rendering or template callables are required.
- Keep custom engines thin adapters over the underlying template library.
- Validate missing-template behavior and callable registration in tests before adopting a custom engine broadly.
