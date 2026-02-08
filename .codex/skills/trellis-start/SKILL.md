---
name: trellis-start
description: Load Trellis workflow, context, and spec indexes for a Codex session.
metadata:
  short-description: Start a Trellis Codex session
---

# Trellis Start (Codex)

Use this skill at the beginning of every Codex session in a Trellis project.

## Steps

1. **Read the workflow guide**

```bash
cat .trellis/workflow.md
```

2. **Check developer identity**

```bash
./.trellis/scripts/get-developer.sh
```

- If the output is empty, **prompt the user** to initialize:

```bash
./.trellis/scripts/init-developer.sh <your-name>
```

3. **Get current context**

```bash
./.trellis/scripts/get-context.sh
```

4. **Read spec indexes**

```bash
cat .trellis/spec/frontend/index.md
cat .trellis/spec/backend/index.md
cat .trellis/spec/guides/index.md
```

5. **Load task context (if any)**

If `.trellis/.current-task` exists, run:

```bash
./.trellis/scripts/get-codex-context.sh
```

If there is no active task or the script is missing, report that clearly.

6. **Summarize and ask**

Briefly summarize what you loaded and ask: **"What would you like to work on next?"**
