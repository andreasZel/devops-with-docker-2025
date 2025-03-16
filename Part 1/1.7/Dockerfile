FROM ubuntu:24.04

WORKDIR /usr/src/app

RUN apt update && apt install -y curl

COPY ./script.sh .

CMD ./script.sh