---
name: litestar-security
description: Build secure Litestar APIs using authentication middleware, built-in security backends, guards, endpoint inclusion and exclusion controls, JWT validation, request-boundary discipline, and secret-safe data handling. Use when implementing or auditing end-to-end API security controls in Litestar. Do not use for generic request parsing, unrelated business logic, or non-security transport concerns.
---

# Security

Use this skill when a Litestar service needs defense-in-depth security implementation, not only authentication wiring.

For full implementation patterns, open [references/security-patterns.md](references/security-patterns.md).

## Execution Workflow

1. Define public, authenticated, and privileged route classes first.
2. Choose the authentication mechanism and attach it once at app scope.
3. Keep request parsing concerns separate from identity establishment.
4. Consume authenticated context from `request.user` / `request.auth` only after auth runs.
5. Apply guards for authorization and ownership checks.
6. Normalize `401` and `403` behavior intentionally and document exclusions.
7. Store and compare secrets safely.

## Implementation Rules

- Keep authentication separate from authorization.
- Parse client inputs with `litestar-requests`; do not re-parse headers or cookies manually inside guards unless the protocol truly requires it.
- Treat `request.user` and `request.auth` as authenticated context, not as generic request-parsing helpers.
- Prefer built-in security backends before custom middleware.
- Keep guard functions deterministic and side-effect free.
- Make exclusion rules narrow, explicit, and tested.
- Use `NotAuthorizedException` for identity failures and `PermissionDeniedException` for insufficient privileges unless the project has a documented alternative contract.
- Keep secrets in `SecretString` / `SecretBytes` and compare them with constant-time primitives when relevant.

## Decision Guide

- Use `litestar-authentication` when the task is mostly identity establishment and token/session flow wiring.
- Use this skill when auth, authorization, secret handling, exclusion rules, and failure behavior must be reviewed together.
- Use guards when policy depends on authenticated context plus route intent.
- Use route `opt` and `exclude_opt_key` only when public-route exceptions are deliberate and auditable.

## Validation Checklist

- Confirm unauthenticated requests receive the intended `401` behavior.
- Confirm insufficient privileges receive the intended `403` behavior.
- Confirm guards accumulate across Litestar layers where expected.
- Confirm public-route exclusions are minimal and explicit.
- Confirm secrets never appear in logs, repr output, or error payloads.
- Confirm request parsing and auth context responsibilities stay separate.
- Confirm tests cover missing credentials, invalid credentials, expired or revoked tokens, and insufficient permissions.

## Cross-Skill Handoffs

- Use `litestar-authentication` when the task is narrow and auth-only.
- Use `litestar-requests` for request parsing, secret-bearing headers/body parameters, and multipart/form transport rules.
- Use `litestar-exception-handling` to standardize `401` and `403` response contracts.
- Use `litestar-testing` for auth boundary, guard, exclusion, and regression tests.
- Use `litestar-openapi` to publish security schemes and auth docs for clients.

## Litestar References

- https://docs.litestar.dev/latest/usage/security/index.html
- https://docs.litestar.dev/latest/usage/security/abstract-authentication-middleware.html
- https://docs.litestar.dev/latest/usage/security/security-backends.html
- https://docs.litestar.dev/latest/usage/security/guards.html
- https://docs.litestar.dev/latest/usage/security/excluding-and-including-endpoints.html
- https://docs.litestar.dev/latest/usage/security/jwt.html
- https://docs.litestar.dev/latest/usage/security/secret-datastructures.html
