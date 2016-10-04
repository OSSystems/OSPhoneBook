FROM ruby:2.2

MAINTAINER https://github.com/OSSystems

ENV DEBIAN_FRONTEND noninteractive

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN gem install bundler
RUN bundle install --without development test

COPY . /usr/src/app

RUN mkdir -p /srv/phonebook/database

RUN RAILS_ENV=production rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["/usr/src/app/bin/entrypoint.sh"]

CMD ["/usr/src/app/bin/start-server.sh"]
