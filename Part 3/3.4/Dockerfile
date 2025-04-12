FROM docker:dind

RUN apk add --no-cache git

WORKDIR /usr/src/app

COPY . .

RUN chmod +x ./update_script.sh

ENTRYPOINT ["./update_script.sh"]
