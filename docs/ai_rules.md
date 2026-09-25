# AI development contract

The legacy package is immutable reference material. Do not copy it by default.
New abstractions require an independently justified reusable contract.

Prohibited:

- Domain types, application policy or database knowledge in the generic package.
- Router/state-management dependencies or responsive scaling packages.
- Page-specific breakpoints, width-based font scaling or title-length scaling.
- Fixed total field heights or FittedBox to bypass user text scaling.
- Rename-only shadcn wrappers or a competing Material visual authority.
- Direct src imports from external consumers.
- Hardcoded package-owned user-facing strings.
- Compatibility aliases or preservation of the old public barrel.
- Changing tests to legitimize architectural violations.

Use the active shadcn theme, inherited Directionality and TextScaler, local
constraints and caller-owned strings. Controllers and validation belong to the
caller; layout owns neither scrolling nor actions. Public exports use explicit
show lists. Do not add a second form engine without revisiting the contract.

Maintain behavior tests and architecture guards. Mutation-test new critical
guards with an actual temporary source/config violation, confirm the intended
failure, restore the source, and confirm the baseline passes.

Run tests from the canonical locations in testing.md. Never repair, format or
resolve dependencies inside the legacy reference as part of new package work.
Stop after Phase 01; Phase 02 requires explicit user approval.
