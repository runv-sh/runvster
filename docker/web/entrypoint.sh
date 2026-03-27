#!/usr/bin/env bash
set -euo pipefail

if [[ -f "Gemfile" ]]; then
  bundle check || bundle install
fi

exec "$@"

