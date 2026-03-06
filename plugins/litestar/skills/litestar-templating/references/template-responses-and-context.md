# Template Responses And Context

## Table of Contents

- Returning `Template` responses
- Template files vs. inline strings
- Passing context explicitly
- Accessing the request in templates
- Adding CSRF inputs

## Returning `Template` Responses

Once `template_config` is registered, handlers can return `litestar.response.Template`.

```python
from litestar import get
from litestar.response import Template


@get("/info")
def info() -> Template:
    return Template(template_name="info.html.jinja2", context={"title": "Info"})
```

Guidance:

- Keep the return annotation as `Template` when the route always renders HTML.
- Keep `template_name` stable and explicit.
- Treat missing templates as configuration errors worth surfacing quickly.

## Template Files Vs. Inline Strings

Litestar supports file-based templates and inline string templates.

File-based template:

```python
from litestar import get
from litestar.response import Template


@get("/page")
def page() -> Template:
    return Template(template_name="page.html.jinja2", context={"hello": "world"})
```

Inline string template:

```python
from litestar import get
from litestar.response import Template


@get("/fragment")
def fragment() -> Template:
    return Template(template_str="<strong>{{ hello }}</strong>", context={"hello": "world"})
```

Guidance:

- Prefer file-based templates for normal pages, layouts, and reusable fragments.
- Use `template_str` for very small snippets, HTMX fragments, or narrow inline cases.
- Expect a missing `template_name` to raise `TemplateNotFoundException`.

## Passing Context Explicitly

`Template.context` is a string-keyed mapping passed to the template renderer.

```python
from litestar import get
from litestar.response import Template


@get("/dashboard")
def dashboard() -> Template:
    context = {
        "page_title": "Dashboard",
        "stats": {"users": 12, "errors": 0},
    }
    return Template(template_name="dashboard.html.jinja2", context=context)
```

Guidance:

- Keep context keys stable and predictable.
- Shape context for the view instead of passing raw services or database sessions.
- Avoid calculations in templates when the handler can prepare the value once.

## Accessing The Request In Templates

The current `Request` is available in template context under `request`.

Jinja or MiniJinja example:

```html
<span>{{ request.app.state.some_key }}</span>
```

Mako example:

```html
<span>${request.app.state.some_key}</span>
```

Guidance:

- Use `request` for presentation-aware access such as app state, current URL information, or helper behavior.
- Do not use template-level `request` access as a substitute for normal handler preparation.

## Adding CSRF Inputs

With CSRF protection configured, templates can render a hidden input using `csrf_input`.

```html
<form method="post">
    {{ csrf_input | safe }}
    <input type="text" name="first_name">
</form>
```

Guidance:

- Mark `csrf_input` as safe so the hidden input is not escaped.
- Use `csrf_input` for normal HTML forms.
- Use `csrf_token` when the token must be embedded somewhere else, such as a meta tag or JavaScript bootstrap data.
- Do not assume CSRF helpers exist unless CSRF protection has been configured.
