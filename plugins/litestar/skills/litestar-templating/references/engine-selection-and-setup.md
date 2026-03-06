# Engine Selection And Setup

## Table of Contents

- Installing engine extras
- Registering built-in engines
- Using one or many template directories
- Using a prebuilt engine instance
- Accessing and customizing the engine instance

## Installing Engine Extras

Litestar ships templating support behind optional extras.

- Install `litestar[jinja]` for Jinja.
- Install `litestar[mako]` for Mako.
- Install `litestar[minijinja]` for MiniJinja.
- If the project already uses `litestar[standard]`, Jinja is already included.

Guidance:

- Match the installed extra to the engine import used in code.
- Treat missing extras as an environment issue first, not a handler bug.

## Registering Built-In Engines

Register templating once at app creation via `TemplateConfig`.

```python
from pathlib import Path

from litestar import Litestar
from litestar.contrib.jinja import JinjaTemplateEngine
from litestar.template.config import TemplateConfig


app = Litestar(
    route_handlers=[...],
    template_config=TemplateConfig(
        directory=Path("templates"),
        engine=JinjaTemplateEngine,
    ),
)
```

Swap the engine import to `MakoTemplateEngine` or `MiniJinjaTemplateEngine` when the project uses those engines.

Guidance:

- Configure the engine at the app boundary, not inside handlers.
- Keep template suffixes consistent with the configured engine.
- Reach for multiple template engines only if the codebase already has a deliberate mixed-engine design.

## Using One Or Many Template Directories

`TemplateConfig.directory` can be a single path or a list of paths.

```python
from pathlib import Path

from litestar.template.config import TemplateConfig
from litestar.contrib.jinja import JinjaTemplateEngine


template_config = TemplateConfig(
    directory=[Path("templates/shared"), Path("templates/admin")],
    engine=JinjaTemplateEngine,
)
```

Use this when template lookup legitimately spans more than one root.

Guidance:

- Prefer a single root unless the project already separates shared and feature-local templates.
- Keep lookup order intentional so filename collisions do not become ambiguous.

## Using A Prebuilt Engine Instance

If the project needs full control over the template environment or loader, pass `instance=` instead of `directory=`.

```python
from jinja2 import DictLoader, Environment

from litestar import Litestar
from litestar.contrib.jinja import JinjaTemplateEngine
from litestar.template.config import TemplateConfig


custom_env = Environment(loader=DictLoader({"index.html": "Hello {{ name }}!"}))

app = Litestar(
    route_handlers=[...],
    template_config=TemplateConfig(
        instance=JinjaTemplateEngine.from_environment(custom_env),
    ),
)
```

Guidance:

- Do not pass `directory` together with `instance`.
- Use `instance=` only when a preconfigured engine object is genuinely required.
- Once you choose `instance=`, engine construction and loader behavior are your responsibility.

## Accessing And Customizing The Engine Instance

Use `engine_callback=` for centralized one-time customization of the instantiated engine.

```python
from pathlib import Path

from litestar.contrib.jinja import JinjaTemplateEngine
from litestar.template.config import TemplateConfig


def configure_templates(engine: JinjaTemplateEngine) -> None:
    engine.register_template_callable(key="app_name", template_callable=lambda ctx: "Admin")


template_config = TemplateConfig(
    directory=Path("templates"),
    engine=JinjaTemplateEngine,
    engine_callback=configure_templates,
)
```

The reference API also exposes `TemplateConfig.engine_instance` and `to_engine()` for cases that need access to the instantiated engine object.

Guidance:

- Prefer `engine_callback` over handler-local mutation so engine behavior stays centralized.
- Use engine access for filters, globals, or callables that belong to presentation setup.
- Avoid late, per-request engine mutation.
