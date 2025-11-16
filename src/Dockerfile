FROM ruby:3.1.4

RUN apt-get update -qq \
  && apt-get install -y nodejs build-essential

# for bundler mismatch: force the bundler version used to match Gemfile.lock
ARG BUNDLER_VERSION=2.6.5
RUN gem install bundler -v $BUNDLER_VERSION

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

COPY . .
