FROM ubuntu

MAINTAINER Harrison Powers, fijimunkii@gmail.com

RUN apt-get update && apt-get install -y curl && \
  curl -sL https://deb.nodesource.com/setup_7.x | bash -

RUN apt-get update && apt-get install -y --no-install-recommends \
  nodejs vim nano build-essential wget openssh-client git python \
  xvfb x11vnc

COPY . /usr/src/app
WORKDIR /usr/src/app

RUN npm i

RUN useradd -d /hubot -m -s /bin/bash -U hubot
USER hubot

ENV HUBOT_PORT 8000
ENV HUBOT_ADAPTER slack
ENV HUBOT_NAME hubot
ENV HUBOT_SLACK_TEAM fijimunkii
ENV HUBOT_SLACK_BOTNAME hubot
ENV PORT ${HUBOT_PORT}
EXPOSE ${HUBOT_PORT}

CMD bin/hubot -a slack
