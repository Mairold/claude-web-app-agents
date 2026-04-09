# Clean Code Conventions

All agents and implementation must follow these rules:

- **Names & size:** Intent-revealing names. Functions ≤20 lines, 0–2 args. Single responsibility. DI.
- **Error handling:** Exceptions not return codes. No null returns — use Optional/empty collections. Every thrown exception must be logged (at minimum WARN level) — use a global exception handler to guarantee nothing is unlogged. Never log sensitive data (passwords, tokens, PII, session IDs).
- **Design:** No side effects. Command-query separation. Law of Demeter (no chaining).
- **Abstraction:** DRY but don't over-abstract. Delete dead code. Prefer well-named methods over comments. No Javadoc on private methods.
- **Tests:** Arrange-Act-Assert. One concept per test. Same quality as production code.
- **Discipline:** Boy Scout Rule. Minimal design. Only extract when clearly needed.
