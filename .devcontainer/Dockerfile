# Dev Container image for community_foundation.
# Matches the repo's .ruby-version (4.0.2) and the production Dockerfile base.
# Adds the build toolchain plus Chromium for Capybara/Selenium system tests.
ARG RUBY_VERSION=4.0.2
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

# System packages:
#   build-essential, git, libyaml-dev, pkg-config  -> compiling native gems (sqlite3, etc.)
#   libvips, sqlite3, curl                          -> runtime deps (Active Storage variants, DB CLI)
#   chromium, chromium-driver                       -> headless system tests (driven_by :selenium)
#   libjemalloc2                                    -> matches prod base (optional, harmless)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git curl \
      libvips libyaml-dev pkg-config sqlite3 libjemalloc2 \
      chromium chromium-driver && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# The system test suite runs as root in this container, and Chromium refuses to
# start its sandbox as root ("Running as root without --no-sandbox is not
# supported", crbug.com/638180). The test files call `driven_by :selenium, using:
# :headless_chrome`, and Rails' own driver registration overwrites any Capybara
# driver configured in Ruby, so the flag can't be injected from the test setup
# without editing the test files. Instead, shim the browser binary itself:
# chromedriver auto-detects Chrome at /usr/bin/chromium, so move the real binary
# aside and put a wrapper there that always appends the container-required flags.
# (Upstream CI runs as non-root, where the sandbox works and this shim is absent.)
RUN mv /usr/bin/chromium /usr/bin/chromium.real && \
    printf '#!/bin/sh\nexec /usr/bin/chromium.real --no-sandbox --disable-dev-shm-usage "$@"\n' > /usr/bin/chromium && \
    chmod +x /usr/bin/chromium

# Capybara/Selenium look up the browser + driver by these names.
ENV CHROME_BIN=/usr/bin/chromium \
    BUNDLE_PATH=/usr/local/bundle

WORKDIR /workspace
