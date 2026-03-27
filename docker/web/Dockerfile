FROM ruby:3.3-bookworm

ARG BUNDLER_VERSION=2.5.22

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  git \
  libpq-dev \
  libvips \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v ${BUNDLER_VERSION}

WORKDIR /workspace/apps/web

COPY docker/web/entrypoint.sh /usr/local/bin/runvster-entrypoint
RUN chmod +x /usr/local/bin/runvster-entrypoint

ENTRYPOINT ["runvster-entrypoint"]

