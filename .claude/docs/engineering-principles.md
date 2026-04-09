# Engineering Principles

1. Zero silent failures — every exception has a name and a visible effect
2. Every error path is traced — happy path is never the only path
3. Every thrown exception is logged — no exception may propagate without a log statement (at minimum WARN level). Use a global exception handler (e.g. `@ControllerAdvice` in Spring) so nothing slips through. **Never log sensitive data** (passwords, tokens, PII, session IDs) — sanitize or mask before logging.
4. Diagrams are mandatory for state machines and multi-step flows
5. Everything deferred is written down — no mental IOUs
6. Optimize for the developer reading this in 6 months
7. When in doubt, implement the complete version — marginal cost is zero
