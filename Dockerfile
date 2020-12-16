FROM ruby:2.6.3-alpine

ENV LANG C.UTF-8
ENV ROOT 3000
ENV APP_ROOT /usr/src/app
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT

RUN apk update && \
    apk --update --no-cache add \
    postgresql-client \
    tzdata \
    nodejs && \
    apk --update --no-cache --virtual=build-dependencies add \
    shadow \
    sudo \
    busybox-suid \
    alpine-sdk \
    postgresql-dev && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'gem: --no-document' >> ~/.gemrc && \
    cp ~/.gemrc /etc/gemrc && \
    chmod uog+r /etc/gemrc && \
    bundle config --global jobs 4 && \
    bundle install --without development test && \
    rm -rf ~/.gem && \
    apk del build-dependencies

COPY . $APP_ROOT

CMD ["bundle", "exec", "rails", "s", "puma", "-b", "0.0.0.0", "-e", "production"]
