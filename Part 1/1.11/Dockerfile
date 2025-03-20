FROM openjdk:8 

EXPOSE 8080

WORKDIR /usr/src/app

RUN git clone https://github.com/docker-hy/material-applications.git && \
    cp -a material-applications/spring-example-project/. . && \
    rm -rf material-applications

COPY . .

RUN ./mvnw package

CMD ["java","-jar","./target/docker-example-1.1.3.jar"]