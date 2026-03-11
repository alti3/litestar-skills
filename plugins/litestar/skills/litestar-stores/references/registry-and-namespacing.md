# Registry And Namespacing

Use this reference when the important design problem is how stores are discovered, shared, and isolated across the app.

## `StoreRegistry`

Purpose:

- Central registry for store instances.
- Available through `app.stores`.
- Used by Litestar features and integrations to resolve named stores.

Core behavior:

- Start with an optional mapping of names to stores.
- `get(name)` returns an existing store or creates one through `default_factory`.
- Newly created stores are registered under that name for later reuse.

## Default Factory

By default:

- The registry creates a new `MemoryStore` when an unknown name is requested.

Why override it:

- You want unknown names to use a shared backend policy.
- You want each integration to receive a namespaced child store automatically.
- You want one Redis or Valkey root store to host multiple isolated logical stores.

Pattern:

- Pass a `StoreRegistry(default_factory=...)` directly to `Litestar`.
- Use a factory that derives stores from the requested name.

## Explicit Registration

- `register(name, store, allow_override=False)` is the explicit way to seed or change registry contents.
- Duplicate registration without override raises `ValueError`.

Practical rule:

- Use explicit registration for well-known stores.
- Use the default factory for scalable conventions.

## Namespacing

Purpose:

- Prevent collisions between features sharing one backend.
- Make `delete_all()` safe inside a logical boundary.
- Support hierarchical store layouts.

Mechanics:

- Namespaced backends expose `with_namespace(namespace)`.
- Child stores affect only their own namespace subtree.
- A root namespaced store can still clear everything by calling `delete_all()` at the root.

## Integration Wiring

Important Litestar patterns:

- Response caching resolves a named store, defaulting to `response_cache` unless configured otherwise.
- Server-side sessions resolve a named store, defaulting to `sessions` unless configured otherwise.
- Rate limiting also resolves its store by name.

Design implication:

- These names are conventions from config defaults, not hard-coded requirements.
- You can reuse one backend by pointing several integrations at one named store or by giving each feature its own name/namespace.

## Strong Default Pattern

Good production pattern:

- Create one Redis or Valkey root store.
- Use `StoreRegistry(default_factory=root_store.with_namespace)`.
- Let each integration resolve its own namespaced child through `app.stores.get(name)`.

Why it works:

- Minimal boilerplate.
- Shared connection/client.
- Strong logical isolation.
- Safe namespace-scoped bulk operations.
