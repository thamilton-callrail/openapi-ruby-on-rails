FROM ruby:3.1-alpine

ENV BUILD_PACKAGES="curl-dev ruby-dev build-base" \
    DEV_PACKAGES="zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev" \
    RUBY_PACKAGES="ruby-json yaml nodejs"

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update\
    $BUILD_PACKAGES \
    $DEV_PACKAGES \
    $RUBY_PACKAGES \
    gcompat && \
    mkdir -p /usr/src/myapp

WORKDIR /usr/src/myapp

COPY Gemfile ./
# Ruby 3.1+ includes bundler by default
RUN bundler --version
RUN bundle config set --local force_ruby_platform true
RUN bundle config set --local build.sqlite3 --with-cflags=-O2
RUN bundle config set --local build.sqlite3 --with-cflags=-O2
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --jobs=4 --retry=10 && \
    bundle clean --force

COPY . ./
RUN chmod +x bin/rails

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
