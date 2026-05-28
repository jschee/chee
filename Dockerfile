FROM ruby:3.3.6-slim

ENV APP_HOME=/app
ENV RACK_ENV=production
ENV BUNDLE_WITHOUT=development:test

WORKDIR $APP_HOME

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      gcc \
      g++ \
      make \
      libc6-dev \
      libpq-dev \
      pkg-config \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]