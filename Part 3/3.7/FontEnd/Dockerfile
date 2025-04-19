FROM node:16-alpine

EXPOSE 5000

WORKDIR /usr/src/app

RUN apk add --no-cache openjdk8 tzdata

COPY ./example-frontend .

RUN npm install -f && \ 
    npm run build && \
    npm install -g serve && \
    adduser -D appuser

USER appuser

CMD ["serve", "-s", "-l", "5000", "build"]