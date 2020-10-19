FROM ruby:2.5-alpine3.11
WORKDIR /app
COPY . /app/

RUN apk update && apk add --virtual build-dependencies build-base
RUN apk add libxslt-dev libxml2-dev
RUN apk add postgresql-dev

RUN gem install bundler
RUN bundle install

CMD ruby main.rb




