FROM ruby:3.4.6-trixie

ENV BUILD_PACKAGES="curl ruby-dev build-essential libxml2-dev libxslt1-dev" \
    DEV_PACKAGES="zlib1g-dev libxml2-dev libxslt-dev tzdata libyaml-dev libsqlite3-dev libffi-dev" \
    RUBY_PACKAGES="nodejs"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    $BUILD_PACKAGES \
    $DEV_PACKAGES \
    $RUBY_PACKAGES && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/src/myapp

EXPOSE 3000

WORKDIR /usr/src/myapp

COPY Gemfile ./

RUN bundler --version
RUN bundle config set --local force_ruby_platform true
RUN bundle config set --local build.sqlite3 --with-cflags=-O2
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install --jobs=4 --retry=10 && \
    bundle clean --force

COPY . ./
RUN chmod +x bin/rails

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["bin/rails", "s", "-b", "0.0.0.0", "-p", "3000"]