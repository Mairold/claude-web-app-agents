# Engineering Principles

1. Zero silent failures — every exception has a name and a visible effect
2. Every error path is traced — happy path is never the only path
3. Every thrown exception is logged — no exception may propagate without a log statement (at minimum WARN level). Use a global exception handler (e.g. `@ControllerAdvice` in Spring) so nothing slips through. Sensitive-data logging rules: see `.claude/docs/security-conventions.md`.
4. Diagrams are mandatory for state machines and multi-step flows
5. Everything deferred is written down — no mental IOUs
6. Optimize for the developer reading this in 6 months
7. When in doubt, implement the complete version — marginal cost is zero
8. **DB changes first, external resources follow.** When a change spans the DB and an external store (S3, filesystem, queue, third-party API), make the DB changes first, then perform the external operation. If the external operation fails and an exception is thrown then our middleware will roll back the DB transaction. Do not compensate with extra writes. Rationale: a broken DB reference (row pointing to a non-existent external object) is worse than a transient failure that leaves both sides unchanged.
