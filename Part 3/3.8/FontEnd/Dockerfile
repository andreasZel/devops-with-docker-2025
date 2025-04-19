FROM node:16-alpine AS buildstage

WORKDIR /usr/src/app

RUN apk add --no-cache openjdk8 tzdata

COPY ./example-frontend .

RUN npm install -f && \ 
    npm run build


FROM node:16-alpine

EXPOSE 5000

WORKDIR /usr/src/app

COPY --from=buildstage /usr/src/app/build/ /usr/src/app/build/
RUN npm install -g serve && adduser -D appuser

USER appuser

CMD ["serve", "-s", "-l", "5000", "build"]