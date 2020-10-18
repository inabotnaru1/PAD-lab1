FROM ruby:2.5
WORKDIR /app
COPY . /app/

COPY Gemfile Gemfile.lock ./

RUN apt-get update -qq && apt-get install -y build-essential
RUN gem install bson -v '4.10.1' --source 'https://rubygems.org/'

RUN gem install bundler
RUN bundle install

COPY . .

CMD ruby main.rb



