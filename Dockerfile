FROM ruby:2.5.1-alpine3.7

MAINTAINER https://github.com/OSSystems

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apk --update --no-cache add libxml2 nodejs sqlite-libs

RUN apk --update --no-cache --virtual /root/build-deps add build-base libffi-dev libxml2-dev linux-headers ruby-dev sqlite-dev

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN gem install bundler
RUN bundle install --without development test

RUN apk \
    del /root/build-deps

COPY . /usr/src/app

RUN mkdir -p /srv/phonebook/database

RUN RAILS_ENV=production rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["/usr/src/app/bin/entrypoint.sh"]

CMD ["/usr/src/app/bin/start-server.sh"]
