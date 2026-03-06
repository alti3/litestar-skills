# Subsystem Patterns

## Table of Contents

- Request parsing bugs
- Auth and guard bugs
- Response contract bugs
- Exception mapping bugs
- Lifecycle and startup bugs

## Request Parsing Bugs

Symptoms:

- unexpected `400` validation failures
- wrong aliases or body shape
- multipart inputs not binding as expected

Debugging moves:

- Reduce the handler to the smallest parameter set that still fails.
- Compare the client payload to the typed handler signature.
- Use `litestar-requests` once the failing transport boundary is clear.

## Auth And Guard Bugs

Symptoms:

- `request.user` missing unexpectedly
- excluded routes behaving as protected or vice versa
- `401` vs `403` mismatches

Debugging moves:

- Reproduce with one protected route and one excluded route.
- Inspect auth backend registration and exclusion rules.
- Use `litestar-authentication` or `litestar-security` for the fix once isolated.

## Response Contract Bugs

Symptoms:

- wrong status code
- undocumented headers or cookies
- stream, file, or SSE behavior not matching expectations

Debugging moves:

- Reduce to one route and inspect the return type plus decorator config.
- Compare runtime behavior to the documented schema.
- Use `litestar-responses` when the response boundary is the real issue.

## Exception Mapping Bugs

Symptoms:

- wrong status code on failure
- inconsistent error envelope
- route or app handler precedence behaving unexpectedly

Debugging moves:

- Reproduce with one exception type and one handler layer at a time.
- Inspect app vs route exception handler registration.
- Use `litestar-exception-handling` for the actual implementation fix.

## Lifecycle And Startup Bugs

Symptoms:

- resources not initialized or torn down correctly
- startup hooks failing silently
- behavior differs between fresh boot and hot reload

Debugging moves:

- Reproduce with one startup hook or lifespan context manager.
- Confirm ordering assumptions with logs or tests.
- Use `litestar-app-setup` or `litestar-lifecycle-hooks` once the lifecycle boundary is clear.
