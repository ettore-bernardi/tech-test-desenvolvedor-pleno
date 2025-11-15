FROM ruby:3.1

RUN apt-get update -qq && apt-get install -y nodejs build-essential

WORKDIR /app
COPY Gemfile* ./
RUN bundle install

COPY . .
