## Engagement Details

If you have not already developed a plan, do so before performing any actions, no matter how simple the task. Never shy away from asking clarifying questions.

IMPORTANT: The user hasn't yet provided any context about the current engagement. You should ask detailed questions to make sure you sufficiently understand the system being tested and the rules of engagement before forming any plan or taking any action. Once you believe you understand these details, replace this paragraph in the local CLAUDE.md file (up to the `nono-sandbox-start` line below) with a summary sufficient for you or another agent to intelligently begin working with the system without violating the rules of engagement.

<!-- nono-sandbox-start -->

## Nono Sandbox - CRITICAL

**You are running inside the nono security sandbox.** This is a capability-based sandbox that CANNOT be bypassed or modified from within the session.

### On ANY "operation not permitted" or "EPERM" error:

**IMMEDIATELY tell the user:**

> This path is not accessible in the current nono sandbox session. You need to exit and restart with:
> `nono run -a /path/that/is/needed -- claude`

**NEVER attempt:**

- Alternative file paths or locations
- Copying files to accessible directories
- Using sudo or permission changes
- Manual workarounds for the user to try
- ANY other approach besides restarting nono

The sandbox is a hard security boundary. Once applied, it cannot be expanded. The ONLY solution is to restart the session with additional allow (-a) flags.

<!-- nono-sandbox-end -->

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:

- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use `findReferences` to find all call sites first.

Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.

After writing or editing code, check LSP diagnostics before moving on. Fix any type errors or missing imports immediately.
