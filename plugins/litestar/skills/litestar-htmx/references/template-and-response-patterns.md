# Template And Response Patterns

## Table of Contents

- `HTMXTemplate`
- Full-page vs fragment rendering
- Redirect and refresh responses
- History and DOM-changing responses

## `HTMXTemplate`

`HTMXTemplate` wraps Litestar's normal `Template` response with HTMX-specific response headers.

```python
from litestar import get
from litestar.plugins.htmx import HTMXRequest, HTMXTemplate
from litestar.response import Template


@get("/form")
def get_form(request: HTMXRequest) -> Template:
    context = {"title": "Contact form"}
    return HTMXTemplate(
        template_name="form/_fields.html.jinja2",
        context=context,
        push_url="/form",
        re_swap="outerHTML",
        re_target="#form-shell",
        trigger_event="formReady",
        params={"mode": "contact"},
        after="swap",
    )
```

Guidance:

- Keep the return annotation as `Template`, not `HTMXTemplate`.
- Use `push_url` to update browser history or pass `False` to suppress it.
- Use `re_swap` and `re_target` only when the handler should override the client-side HTMX defaults.
- If `trigger_event` is set, provide `after=` as `receive`, `settle`, or `swap`.

## Full-Page Vs Fragment Rendering

A common HTMX pattern is one route that renders a full page for normal navigation and a partial for HTMX swaps.

```python
from litestar import get
from litestar.plugins.htmx import HTMXRequest, HTMXTemplate
from litestar.response import Template


@get("/todos")
def list_todos(request: HTMXRequest) -> Template:
    context = {"todos": [{"title": "Ship feature"}]}
    if request.htmx:
        return HTMXTemplate(template_name="todos/_list.html.jinja2", context=context)
    return Template(template_name="todos/index.html.jinja2", context=context)
```

Guidance:

- Keep the fragment template layout-free whenever possible.
- Share context preparation, not template files, when page and fragment requirements differ materially.

## Redirect And Refresh Responses

Use the dedicated no-DOM-change responses when the HTMX client should redirect, refresh, or stop polling.

### `ClientRedirect`

```python
from litestar import post
from litestar.plugins.htmx import ClientRedirect


@post("/session/expired")
def session_expired() -> ClientRedirect:
    return ClientRedirect(redirect_to="/login")
```

Use this when:

- the browser should navigate with a full reload
- the HTMX flow should end in a normal page load

### `ClientRefresh`

```python
from litestar import post
from litestar.plugins.htmx import ClientRefresh


@post("/settings/reload")
def reload_settings() -> ClientRefresh:
    return ClientRefresh()
```

Use this when:

- the whole page must refresh because multiple page regions depend on the updated state

### `HXStopPolling`

```python
from litestar import get
from litestar.plugins.htmx import HXStopPolling


@get("/jobs/42/status")
def job_status() -> HXStopPolling:
    return HXStopPolling()
```

Use this when:

- an HTMX polling loop should terminate explicitly

## History And DOM-Changing Responses

Use these response classes when the response still carries content or instructs HTMX to adjust browser or DOM behavior.

### `HXLocation`

```python
from litestar import post
from litestar.plugins.htmx import HXLocation


@post("/wizard/next")
def wizard_next() -> HXLocation:
    return HXLocation(
        redirect_to="/wizard/step-2",
        target="#wizard-shell",
        swap="outerHTML",
        values={"step": "2"},
    )
```

Use this when:

- the client should navigate without a full page reload
- the redirect needs HTMX-specific target, select, swap, values, or headers

### `PushUrl` And `ReplaceUrl`

```python
from litestar import get
from litestar.plugins.htmx import PushUrl, ReplaceUrl


@get("/products/filter")
def filter_products() -> PushUrl[str]:
    return PushUrl(content="<div>Filtered</div>", push_url="/products?in_stock=1")


@get("/search")
def canonical_search() -> ReplaceUrl[str]:
    return ReplaceUrl(content="<div>Results</div>", replace_url="/search?q=litestar")
```

Use this when:

- the response body should still be swapped in
- and the URL bar or history stack must also change

### `Reswap`, `Retarget`, And `TriggerEvent`

```python
from litestar import post
from litestar.plugins.htmx import Reswap, Retarget, TriggerEvent


@post("/messages")
def create_message() -> TriggerEvent[str]:
    return TriggerEvent(
        content="<div>Saved</div>",
        name="messageSaved",
        params={"level": "success"},
        after="settle",
    )


@post("/cards/swap")
def change_swap() -> Reswap[str]:
    return Reswap(content="<article>Updated</article>", method="beforeend")


@post("/cards/retarget")
def change_target() -> Retarget[str]:
    return Retarget(content="<article>Updated</article>", target="#secondary-panel")
```

Guidance:

- Use `Reswap` when the swap strategy must come from the server.
- Use `Retarget` when the server decides which element should receive the content.
- Use `TriggerEvent` when the client should react after `receive`, `settle`, or `swap`.
