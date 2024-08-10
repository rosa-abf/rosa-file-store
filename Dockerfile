FROM ruby:3.3.4-alpine3.20 as fstore-gems

WORKDIR /file_store
RUN apk add --no-cache libpq ca-certificates tzdata libstdc++ && apk add --virtual .ruby-builddeps --no-cache postgresql-dev build-base
RUN gem update --system
RUN gem install bundler
RUN bundle config set --local clean 'true' && bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && bundle config set --local no-cache 'true'
COPY Gemfile Gemfile.lock ./
RUN apk add --no-cache shared-mime-info nodejs
RUN bundle install --verbose --jobs 16
RUN apk del --no-cache .ruby-builddeps && rm -rf /root/.bundle && rm -rf /file_store/vendor/bundle/ruby/3.3.0/cache

FROM scratch
COPY --from=fstore-gems / /

RUN touch /MIGRATE

ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle

ENV RAILS_ENV=production
ENV DATABASE_URL=postgresql://postgres@postgres/file-store?pool=30

ENV RUBYOPT="--enable-yjit --yjit-exec-mem-size=384"

WORKDIR /file_store
COPY bin ./bin
COPY config ./config
COPY db ./db
COPY app/ ./app
COPY public ./public
COPY Rakefile config.ru entrypoint.sh ./
ENTRYPOINT ["/file_store/entrypoint.sh"]
