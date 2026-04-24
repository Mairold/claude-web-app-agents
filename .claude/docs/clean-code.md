# Clean Code Conventions

All agents and implementation must follow these rules:

- **Names & size:** Intent-revealing names. Functions ≤20 lines, 0–2 args. Single responsibility. DI.
- **No magic numbers:** Extract literals with implicit meaning into named constants (`MAX_RETRIES = 3`, `SESSION_TIMEOUT_MS = 86400000`). Obvious values (`0`, `1`, `-1`, array indices, test fixtures) stay inline.
- **Error handling:** Exceptions not return codes. No null returns — use Optional/empty collections. Every thrown exception must be logged (at minimum WARN level) — use a global exception handler to guarantee nothing is unlogged. Never log sensitive data (passwords, tokens, PII, session IDs).
- **Design:** No side effects. Command-query separation. Law of Demeter (no chaining).
- **Abstraction:** DRY but don't over-abstract. Delete dead code. Comment only WHY. Prefer well-named methods over comments.
- **Tests:** Arrange-Act-Assert. One concept per test. Same quality as production code.
- **File structure:** Public API and exports at the top, private/internal helpers at the bottom. Reader should see the "what" before the "how".
- **Discipline:** Boy Scout Rule. Minimal design. Only extract when clearly needed.
