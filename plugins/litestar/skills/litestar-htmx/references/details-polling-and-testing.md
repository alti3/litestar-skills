# Details, Polling, And Testing

## Table of Contents

- `HTMXDetails` properties
- History-aware flows
- Prompt, trigger, and target metadata
- Testing HTMX handlers

## `HTMXDetails` Properties

The HTMX reference documents these useful `request.htmx` properties:

- truthiness via `bool(request.htmx)` to detect HTMX requests
- `boosted`
- `current_url`
- `current_url_abs_path`
- `history_restore_request`
- `prompt`
- `target`
- `trigger`
- `trigger_name`
- `triggering_event`

Guidance:

- Read these properties from `request.htmx` instead of parsing headers by hand.
- Only branch on the fields that actually affect server behavior.
- Keep business logic independent from raw DOM IDs where possible, even if `target` or `trigger` helps with presentation-level routing.

## History-Aware Flows

`current_url`, `current_url_abs_path`, and `history_restore_request` are useful when one endpoint serves both direct navigation and HTMX-driven history behavior.

```python
from litestar import get
from litestar.plugins.htmx import HTMXRequest, HTMXTemplate
from litestar.response import Template


@get("/inbox")
def inbox(request: HTMXRequest) -> Template:
    context = {
        "history_restore": request.htmx.history_restore_request if request.htmx else False,
        "current_url": request.htmx.current_url_abs_path if request.htmx else None,
    }
    if request.htmx:
        return HTMXTemplate(
            template_name="inbox/_list.html.jinja2",
            context=context,
            push_url="/inbox",
        )
    return Template(template_name="inbox/index.html.jinja2", context=context)
```

Guidance:

- Use history-related properties when rendering depends on the current browser URL or a history restoration path.
- Keep the fallback for non-HTMX requests explicit.

## Prompt, Trigger, And Target Metadata

`prompt`, `target`, `trigger`, `trigger_name`, and `triggering_event` let the server respond differently based on how the HTMX request was initiated.

```python
from litestar import delete
from litestar.plugins.htmx import HTMXRequest, Retarget


@delete("/account")
def delete_account(request: HTMXRequest) -> Retarget[str]:
    prompt_value = request.htmx.prompt if request.htmx else None
    if prompt_value != "confirm":
        return Retarget(content="<p>Confirmation failed</p>", target="#messages")
    return Retarget(content="<p>Deleted</p>", target="#messages")
```

Guidance:

- Use prompt and trigger metadata for interaction logic, not as a substitute for real authorization or validation.
- Keep DOM target values stable so server-selected retargeting remains maintainable.

## Testing HTMX Handlers

Test both direct navigation and HTMX-triggered behavior. Use Litestar's normal test clients and send the HTMX headers the handler depends on.

```python
from litestar import get
from litestar.plugins.htmx import HTMXRequest, HTMXTemplate
from litestar.response import Template
from litestar.testing import create_test_client


@get("/contacts", request_class=HTMXRequest)
def contacts(request: HTMXRequest) -> Template:
    if request.htmx:
        return HTMXTemplate(template_str="<tbody><tr><td>Ada</td></tr></tbody>", context={})
    return Template(template_str="<html><body><table><tbody><tr><td>Ada</td></tr></tbody></table></body></html>", context={})


with create_test_client(route_handlers=[contacts]) as client:
    page_response = client.get("/contacts")
    fragment_response = client.get("/contacts", headers={"HX-Request": "true"})

    assert "<html" in page_response.text
    assert "<tbody>" in fragment_response.text
```

Also test:

- HTMX history flows when `push_url`, `replace_url`, or `HXLocation` are involved
- polling termination paths that return `HXStopPolling`
- event-triggering responses where the timing (`receive`, `settle`, `swap`) matters
- server-selected target and swap behavior when using `Retarget` or `Reswap`

Guidance:

- Assert fragment shape, not just status code.
- For HTMX response classes, assert the response headers or body semantics the client relies on.
- Cover both HTMX and non-HTMX branches whenever one route serves both modes.
