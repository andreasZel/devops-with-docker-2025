FROM openjdk:8 

EXPOSE 5000

WORKDIR /usr/src/app

RUN git clone https://github.com/docker-hy/material-applications.git && \
    cp -a material-applications/example-frontend/. . && \
    rm -rf material-applications && \
    apt-get update; \
    apt-get install -y curl gnupg; \
    curl -sL https://deb.nodesource.com/setup_16.x | bash -; \
    apt-get install -y nodejs; \ 
    apt-get install npm -y; \
    rm -rf /var/lib/apt/lists/* && \
    apt-get -y purge git curl gnupg && apt-get -y autoremove && apt-get clean 

COPY . .

RUN npm install -f && \ 
    npm run build && \
    npm install -g serve && \
    useradd -m appuser

USER appuser

CMD ["serve", "-s", "-l", "5000", "build"]