FROM docker-registry.speedconnect.com/production_rails_base:latest

MAINTAINER Tony DeMatteis <tony.dematteis@speedconnect.net>

WORKDIR /app

COPY ./Gemfile* /app/
RUN bundle install
COPY . /app/

RUN apt update -y && apt install -yqq fping && \
    rm -rf /var/lib/app/*  && rm -rf /tmp/*

COPY shell/resolv.conf /tmp/
COPY docker-entrypoint.sh /
RUN chown root:root /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

EXPOSE 3000

CMD /docker-entrypoint.sh
