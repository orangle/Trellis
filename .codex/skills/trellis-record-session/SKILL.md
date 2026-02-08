---
name: trellis-record-session
description: Record session progress in Trellis via add-session.sh.
metadata:
  short-description: Record a Trellis session summary
---

# Trellis Record Session (Codex)

Use this skill at the end of a session to log progress in the workspace journal.

## Steps

1. **Run the session recorder** (ask the user for title/summary/commits first):

```bash
./.trellis/scripts/add-session.sh \
  --title "<session title>" \
  --commit "<commit hashes>" \
  --summary "<brief summary>"
```

2. **Prompt the user** to verify the workspace index was updated:

```bash
cat .trellis/workspace/index.md
```

If the index looks wrong, advise re-running the command with corrected details.
