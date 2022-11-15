FROM ruby:3.1.1-alpine
MAINTAINER Iwan Buetti <iwan.buetti@gmail.com>

RUN apk --update add --virtual build-dependencies \
                               build-base \
                               libxml2-dev \
                               libxslt-dev \
                               linux-headers \
                               nodejs \
                               tzdata \
                               git \
                               yarn \
                               redis \
                               sqlite-dev \
                               bash \
                               gcompat \
                               icu-dev \
                               sqlite-dev \
                               && rm -rf /var/cache/apk/*

# docker build -t iwan/redcap_out_converter .
# docker build -t iwan/redcap_out_converter:0.5.1-linux-amd64 --platform linux/amd64,linux/arm64 .
# docker run -p 3003:3003 --name roc iwan/redcap_out_converter

ENV app /app
RUN mkdir $app
WORKDIR $app

# default value
ARG var_rails_env='production'

ENV RAILS_ENV=$var_rails_env
ENV RACK_ENV='production'
ENV NODE_ENV='production'
ENV RAILS_SERVE_STATIC_FILES='true'

ENV BUNDLE_PATH /gems
ENV GEM_PATH /gems
ENV GEM_HOME /gems
ADD Gemfile* $app/
RUN bundle config set without 'development test'
RUN bundle check || bundle install

COPY . $app
RUN mkdir -p tmp/pids
RUN bin/rails assets:precompile
RUN gem install foreman
RUN bin/rails db:create db:migrate

EXPOSE 3003

CMD ["bin/production"]
