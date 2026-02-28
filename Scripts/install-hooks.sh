#!/bin/sh
set -eu

repo_root=$(git rev-parse --show-toplevel)
git config core.hooksPath "$repo_root/.githooks"

echo "Configured git hooks path:"
git config --get core.hooksPath
