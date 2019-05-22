FROM debian:stretch-slim

RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    curl unzip wget nano

RUN pip3 install beautifulsoup4 graphyte
RUN pip3 install requests

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONUNBUFFERED=1
ENV GRAPHITE_HOST=graphite

ENV APP_HOME /usr/src/app
WORKDIR /$APP_HOME

COPY . $APP_HOME/
CMD while true; do python3 example.py; sleep 15; done
