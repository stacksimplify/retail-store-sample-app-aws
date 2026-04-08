#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# pre-push-checks.sh
# Guardrail script — runs before every push via hooks/pre-push
# Enforces branch rules, cleanliness checks, runtime versions,
# and lint/test validation. Fails fast if any condition is not met.
# Added Permissions: chmod +x pre-push-checks.sh
# ═══════════════════════════════════════════════════════════════

# ─── Colours ────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=======================================================================${NC}"
echo -e "${BLUE}  🔎 Pre-Push Guardrail Checks${NC}"
echo -e "${BLUE}=======================================================================${NC}"

# ─── 1. Block pushes to main branch ─────────────────────────────
current_branch=$(git symbolic-ref --short HEAD)

echo -e "\n${YELLOW}[1/4] Checking branch...${NC}"
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
  echo -e "${RED}🚫 Direct pushes to '$current_branch' are not allowed.${NC}"
  echo -e "${RED}    Please push to a feature branch and open a pull request.${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Branch is '$current_branch' — safe to push.${NC}"

# ─── 2. Check for uncommitted changes ───────────────────────────
echo -e "\n${YELLOW}[2/4] Checking for uncommitted changes...${NC}"
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo -e "${RED}🚫 You have uncommitted changes. Please commit or stash them before pushing.${NC}"
  git status --short
  exit 1
fi
echo -e "${GREEN}✅ Working tree is clean.${NC}"

# ─── 3. Validate runtime versions ───────────────────────────────
echo -e "\n${YELLOW}[3/4] Validating runtime versions...${NC}"

if [ -f "package.json" ]; then
  # ── Node / React project ──
  required_node="18"
  current_node=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)

  if [ -z "$current_node" ]; then
    echo -e "${RED}🚫 Node.js is not installed or not found in PATH.${NC}"
    exit 1
  fi

  if [ "$current_node" -lt "$required_node" ]; then
    echo -e "${RED}🚫 Node.js v$required_node+ required. Found: v$current_node${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ Node.js version: v$current_node (required: v$required_node+)${NC}"

elif [ -f "requirements.txt" ] || [ -f "manage.py" ] || [ -f "app.py" ]; then
  # ── Python / Django / Flask project ──
  required_python="3"
  current_python=$(python3 --version 2>/dev/null | cut -d' ' -f2 | cut -d. -f1)

  if [ -z "$current_python" ]; then
    echo -e "${RED}🚫 Python 3 is not installed or not found in PATH.${NC}"
    exit 1
  fi

  if [ "$current_python" -lt "$required_python" ]; then
    echo -e "${RED}🚫 Python $required_python+ required. Found: $current_python${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ Python version: $(python3 --version) (required: Python $required_python+)${NC}"

else
  echo -e "${YELLOW}⚠️  No recognised runtime indicator found. Skipping version check.${NC}"
fi

# ─── 4. Lint + test checks via Makefile ─────────────────────────
echo -e "\n${YELLOW}[4/4] Running lint and test checks...${NC}"

if [ -f "Makefile" ]; then
  echo -e "${YELLOW}   Running make check...${NC}"
  if make check; then
    echo -e "${GREEN}✅ All checks passed.${NC}"
  else
    echo -e "${RED}🚫 make check failed. Fix errors before pushing.${NC}"
    exit 1
  fi
else
  echo -e "${YELLOW}⚠️  No Makefile found. Skipping checks.${NC}"
fi

# ─── All checks passed ──────────────────────────────────────────
echo -e "\n${BLUE}=======================================================================${NC}"
echo -e "${GREEN}🚀 All guardrail checks passed. Proceeding with push.${NC}"
echo -e "${BLUE}=======================================================================${NC}"
exit 0
