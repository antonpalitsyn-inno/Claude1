#!/bin/bash
set -euo pipefail

# Only run in remote/web sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Session start hook for Claude Code on the web
# This ensures the environment is properly initialized

# Confirm git is available and repo is clean
git status --short 2>/dev/null || true

exit 0
