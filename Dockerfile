FROM ruby:2.5.3-alpine3.8 as fstore-gems

WORKDIR /file_store
RUN apk add --no-cache libpq ca-certificates tzdata libstdc++ && apk add --virtual .ruby-builddeps --no-cache postgresql-dev build-base
RUN gem install bundler:2.0.1
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test --jobs 16 --clean --deployment --no-cache
RUN apk add --no-cache nodejs
RUN apk del .ruby-builddeps && rm -rf /root/.bundle && rm -rf /file_store/vendor/bundle/ruby/2.5.0/cache

FROM scratch
COPY --from=fstore-gems / /

RUN touch /MIGRATE

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_APP_CONFIG /usr/local/bundle

ENV RAILS_ENV production
ENV DATABASE_URL postgresql://postgres@postgres/file-store?pool=30

WORKDIR /file_store
COPY bin ./bin
COPY config ./config
COPY db ./db
COPY app/ ./app
COPY public ./public
COPY Rakefile config.ru entrypoint.sh ./
ENTRYPOINT ["/file_store/entrypoint.sh"]
