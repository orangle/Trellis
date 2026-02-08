#!/bin/bash
# Get task context for Codex sessions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/paths.sh"

REPO_ROOT=$(get_repo_root)
CURRENT_TASK=$(get_current_task "$REPO_ROOT")

if [[ -z "$CURRENT_TASK" ]]; then
  echo "No active task found (.trellis/.current-task is empty)."
  exit 0
fi

if [[ "$CURRENT_TASK" = /* ]]; then
  TASK_DIR="$CURRENT_TASK"
else
  TASK_DIR="$REPO_ROOT/$CURRENT_TASK"
fi

if [[ ! -d "$TASK_DIR" ]]; then
  echo "Current task directory not found: $TASK_DIR" >&2
  exit 1
fi

MAX_FILES=20
count=0

declare -A seen
context_files=()

print_file() {
  local path="$1"
  local rel="$path"
  if [[ "$path" == "$REPO_ROOT/"* ]]; then
    rel="${path#$REPO_ROOT/}"
  fi

  echo "----- [PATH: $rel] -----"
  cat "$path"
  echo ""
}

add_file() {
  local path="$1"
  if [[ -z "$path" ]] || [[ ! -f "$path" ]]; then
    return
  fi
  if [[ -n "${seen[$path]:-}" ]]; then
    return
  fi
  if [[ $count -ge $MAX_FILES ]]; then
    return
  fi
  seen[$path]=1
  context_files+=("$path")
  count=$((count + 1))
}

collect_from_jsonl() {
  local jsonl="$1"
  if [[ ! -f "$jsonl" ]]; then
    return
  fi

  while IFS=$'\t' read -r entry_type entry_path; do
    if [[ $count -ge $MAX_FILES ]]; then
      break
    fi
    if [[ -z "$entry_path" ]]; then
      continue
    fi

    local resolved="$entry_path"
    if [[ "$entry_path" != /* ]]; then
      resolved="$REPO_ROOT/$entry_path"
    fi

    if [[ "$entry_type" == "directory" ]]; then
      if [[ -d "$resolved" ]]; then
        while IFS= read -r file; do
          add_file "$file"
          if [[ $count -ge $MAX_FILES ]]; then
            return
          fi
        done < <(find "$resolved" -type f -name "*.md" | sort)
      fi
    else
      add_file "$resolved"
    fi
  done < <(
    python3 - "$jsonl" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    for line in handle:
        line = line.strip()
        if not line:
            continue
        try:
            data = json.loads(line)
        except json.JSONDecodeError:
            continue
        entry_path = data.get("file")
        if not entry_path:
            continue
        entry_type = data.get("type", "file")
        print(f"{entry_type}\t{entry_path}")
PY
  )
}

echo "=== Trellis Task Context ==="
echo "Task: $CURRENT_TASK"
echo ""

if [[ -f "$TASK_DIR/prd.md" ]]; then
  print_file "$TASK_DIR/prd.md"
fi

if [[ -f "$TASK_DIR/info.md" ]]; then
  print_file "$TASK_DIR/info.md"
fi

collect_from_jsonl "$TASK_DIR/implement.jsonl"
collect_from_jsonl "$TASK_DIR/check.jsonl"
collect_from_jsonl "$TASK_DIR/debug.jsonl"

if [[ ${#context_files[@]} -gt 0 ]]; then
  echo "=== Referenced Context Files (max $MAX_FILES) ==="
  echo ""
  for path in "${context_files[@]}"; do
    print_file "$path"
  done
else
  echo "No referenced context files found in jsonl context."
fi
