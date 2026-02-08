---
name: trellis-parallel
description: Run Trellis multi-agent parallel workflow using worktrees.
metadata:
  short-description: Launch Trellis parallel worktree pipeline
---

# Trellis Parallel (Codex)

Use this skill to orchestrate the multi-agent parallel workflow from the main repository. You plan and dispatch; work happens inside worktrees.

## Default Flow (Recommended)

1. **Run the Plan agent** (recommended for most requests):

```bash
./.trellis/scripts/multi-agent/plan.sh \
  --name "<feature-name>" \
  --type "<backend|frontend|fullstack>" \
  --requirement "<user requirement description>"
```

2. **Start the worktree agent** once `plan.sh` outputs the task directory:

```bash
./.trellis/scripts/multi-agent/start.sh "$TASK_DIR"
```

3. **Tell the user how to monitor progress**:

```bash
./.trellis/scripts/multi-agent/status.sh
./.trellis/scripts/multi-agent/status.sh --log <name>
./.trellis/scripts/multi-agent/status.sh --watch <name>
```

## Manual Flow (Only for small, clear tasks)

If the requirements are already clear, you may create the task manually with `task.sh` and then run `start.sh`, but default to `plan.sh` unless the task is trivial.

## Guidance

- Stay in the **main repo**. Do **not** implement code directly.
- Summarize the plan, confirm the next steps, and report where the worktree was created.
