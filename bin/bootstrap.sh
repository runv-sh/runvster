#!/usr/bin/env bash
set -euo pipefail

mkdir -p apps/web

docker compose run --rm --no-deps web bash -lc "
  if [ ! -f Gemfile ]; then
    gem install rails -N &&
    /usr/local/bundle/bin/rails new . \
      --force \
      --database=postgresql \
      --javascript=importmap \
      --css=tailwind \
      --skip-jbuilder \
      --skip-test \
      --skip-system-test \
      --skip-ci \
      --skip-kamal \
      --skip-thruster \
      --skip-git \
      --skip-bundle
  fi &&
  bundle install
"
