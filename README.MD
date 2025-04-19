# Notes for DevOps with Docker 2025 Class of MOOC.fi

## Docker

Docker is a set of tools to deliver software in `containers`.

`containers` are packages of software.

Benefits:

1. Avoid **works on my machine problem**
2. **Isolated Environments**, we can have multiple versions of dependencies, and update them
   easyli while test for braking changes
3. **Easy developement**, with one command we can install multiple tools without needing to download them on our system. Also developers in a team can get **the same setup and startup quickly** on a project.
4. **Scaling**, whe can orchestrate multiple containers and even start containers whithin containers for easy scalability.

## VMs vs Containers

Containers run with OS Kernel, they **do not need an OS and all it's libraries and binaries**, make it more **lightweight** and **faster to boot**.

## Running Conteiners

When typing commands, `CLI client` sends request to **Docker Daemon** throught REST API to handle the requests.

We can run a container using an existing image by
typing `docker container run <image-name>:<tag>` or `docker run <image-name>:<tag>`, for example

```bash
docker container run hello-world

#or

docker run hello-world
```

both of them are fetched with `:latest` tag, because whe didn't specify it.

this gets the image on the first time and runs the container. After that there is no need to get the image again, the container will be created and run.

## Image and Containers

`Containers` are `instances of Images`. To put it more simply

1. `Containers` 🍴🥣: Ready to eat Meal
2. `Image` 📖: Recipe and Ingredients to create a Meal

### Image

A typical image format is as follows: `registry/organisation/image:tag`

Image is a file that cannot be changed. They are `Immutable`. You can create new images from a base image and adding layers to it, this type of file is called `DockerFile`.

A typical `DockerFile` is made from some basic instructions, such as:

```docker
FROM <image>:<tag>

RUN <install dependencies>

CMD <command that is run when container starts>
```

we can `list` images with:

```bash
docker image ls
```

### Docker File

### Construction of a Dockerfile

As we said Dockerfile contains the instructions for the image we want to create, some of them are:

1. `FROM <image>:<tag>` the image it starts from.
2. `WORKDIR <directory>` the directory the insructions will be executed.
3. `COPY <source directory> <destination>` copies a file from the directory specified to the `WORKDIR` or current dir.
4. `CMD <command>` a command that will be executed when the container starts.
   - If an `ENTYPOINT` is set on an Image, `CMD` passes the **default parameters** to it.
5. `ENTRYPOINT` is a way to **run a command but having the ability to `pass parameters to it`**. If no ENTRYPOINT is set `/bin/sh -c` is the ENTRYPOINT.

   - We can pass parameters with `CMD` or by running the container. If both CMD and parameter is passed when running the container, CMD will be overriten. For example:

     ```docker
       FROM ubuntu:24.04

       WORKDIR /mydir

       RUN apt-get update && apt-get install -y curl python3
       RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
       RUN chmod a+x /usr/local/bin/yt-dlp

       ENTRYPOINT ["/usr/local/bin/yt-dlp"]

       # define a default argument
       CMD ["https://www.youtube.com/watch?v=Aa55RKWZxxI"]
     ```

     If we built it as example, running:

     ```bash
     # Overrides CMD in Dockerfile
       docker run yt-dlp https://www.youtube.com/watch?v=DptFY_MszQs
     ```

   - There are also two ways to set ENTRYPOINT and CMD:

     1. `exec` form. Basically, we call CMD and ENTRYPOINT with [], it runs the command itself:

        ```docker
        ENTRYPOINT ["/usr/local/bin/yt-dlp"]

        CMD ["localhost"]
        ```

        So output command is:

        ```bash
          /usr/local/bin/yt-dlp /localhost
        ```

     2. `shell` form. The command is provided as a string without brackets, this runs the command by wrapping it with `/bin/sh -c`. So in the same example we would get:

        ```bash
          /bin/sh -c '/usr/local/bin/yt-dlp' /bin/sh -c 'localhost'
        ```

<br />

<table><thead><tr><th >Dockerfile</th><th >Resulting command</th></tr></thead><tbody><tr><td >ENTRYPOINT /bin/ping -c 3<br>CMD localhost</td><td >/bin/sh -c '/bin/ping -c 3' /bin/sh -c localhost</td></tr><tr><td >ENTRYPOINT&nbsp;["/bin/ping","-c","3"]<br>CMD localhost</td><td >/bin/ping -c 3 /bin/sh -c localhost</td></tr><tr><td >ENTRYPOINT /bin/ping -c 3<br>CMD&nbsp;["localhost"]</td><td >/bin/sh -c '/bin/ping -c 3' localhost</td></tr><tr><td >ENTRYPOINT&nbsp;["/bin/ping","-c","3"]<br>CMD&nbsp;["localhost"]</td><td >/bin/ping -c 3 localhost</td></tr></tbody><tfoot></tfoot><caption ></caption></table>

<br />

a basic example would be:

```docker
# Start from the alpine image that is smaller but no fancy tools
FROM alpine:3.21

# Use /usr/src/app as our workdir. The following instructions will be executed in this location.
WORKDIR /usr/src/app

# Copy the hello.sh file from this directory to /usr/src/app/ creating /usr/src/app/hello.sh
COPY hello.sh .

# Add execution permissions during the build.
RUN chmod +x hello.sh

# When running docker run the command will be ./hello.sh
CMD ./hello.sh
```

### Creating an Image from a Dockerfile

To create the image we use `docker build <build location>`
Docker build, search for a Dockerfile and builds it in the specified location.

We can also use the `-t <image name>` flag to name our image. An example would be:

```bash
# build a Dockerfile in the current dir and name it hello-docker
docker build . -t hello-docker
```

<hr />

\*\* **Common Error** \*\*

If we get a message such as "/bin/sh: ./hello.sh: not found", there is an error with the `line endings`. If we use `UNIX` we have to change our line endings to `LF` and save. As a rule of thumb:

1. Windows -> `CRLF`
1. Unix -> `LF`

<hr />

### Layers

Each instruction is a `Layer`, if we already builded a Dockerfile, layers will be `cached`.

So it is wise to construct our layers so that the `changes happens to the bottom layers` in order to make our builds faster.

#### Adding layers while Container is running (Creating new Images)

We can add layers after we run the container.

For example we could:

```bash
touch additional.txt

docker cp ./additional.txt <container id>:<path>

# This will show
#  A /usr/src/app/additional.txt
docker diff <container id>

# Creates a new Image from the commit
docker commit <container id> <new image name>
```

It is generally considered good practise to just use Dockerfiles and version them, rather than commiting changes and creating new images.

\*\* **Tip** \*\*

We can use `ADD` instruction in Dockerfile to add a identity, gzip, bzip2 or xz as an unpacked directory if src is a local tar archive in a recognized compression format.

✅ If something.gzip is actually a .tar.gz (i.e., a compressed tar archive, just with an unconventional extension), it will be unpacked.

❌ If something.gzip is just a gzipped file, not a .tar.gz, then it won’t be unpacked — it will just be copied as-is.

Example:

- something.tar.gz → unpacked ✅

- something.gzip (if it’s actually tar + gzip) → unpacked ✅

- something.gzip (if it’s just a gzipped single file, like you’d get from gzip file.txt) → not unpacked ❌

### Container

Containers are `isolated environments` in the host machine that only contain what is required for the application. We can **start**, **stop** and **interact with eachother or the host machine** via `TCP/UDP`.

we can `list` all containers with:

```bash
docker containers ls -a

# or

docker ps -a
```

## Copy files locally from Container

We can copy files from our container using `docker cp` command, like:

```bash
docker cp "determined_elion://mydir/Welcome to Kumpula campus! ｜ University of Helsinki [DptFY_MszQs].mp4" .
```

## Persisting changes

There are two ways to persist changes, one is `Bind Mounts` and other is `Volumes`.

### Volumes (Bind Mounts)

It allows us to add a directory from the `host's` machine to the `Container` and share it.

To do so we can use the command line, and use the `-v <absolute path in host>:<path in container>` flag, running the container:

```bash
docker run -v "$(pwd):/mydir" yt-dlp https://www.youtube.com/watch?v=saEpkcVi1d4
```

This will output whatever it is on the container to /mydir. We could also use a `specific file` to write only to it.

## Removing Containers and Images

To remove an Image we **HAVE TO** first delete any associated Containers.

We first stop the containers if they are running and then use `docker container rm <container id | container name>`.
We can also use the **starting characters**, for example if the id is `3d4bab29dd67` we could use:

```bash
docker container rm container-id

# or

docker container rm 3d
```

if multiple containers contain that character in the Id we would first get a warning message. Also we can remove multiple containers with:

```bash
docker container rm id1 id2 id3
```

or all stopped containers with `prune`. **Dangling images** also can be removed with prune.

```bash
# for containers
docker container prune

# for images
docker image prune
```

## Running Containers

We can run containers in the current terminal, blocking any input.

```bash
docker run -d <container_id>
```

Flags:

- `-it` flag.
  We can use the `-it` flag to run it as `interactive` meaning we can pass commands to it, the `-t` flag also created a `tty`, or a virtual terminal, combining this we can have a terminal to interact with:

```bash
docker run -it <container_id>
```

- `-d` flag.
  We can use the `-d` flag to run it as `detatched`, meaning it will run in the background:

```bash
docker run -d <container_id>
```

- `--name` flag.
  We can name the container using this flag.

We can also pass some command after the image name or id like:

```bash
$ docker run -d -it --name looper ubuntu sh -c "while true; do date; sleep 1; done"
```

- `--rm` flag.
  Is a very usefull flag that ensures that there are no garbage containers left behind, otherwise we would have to:

  - `docker kill <container_id>`
  - `docker rm <container_id>`

- `--no-stdin` flag.
  Prevents an `attached` terminal from stopping if we `CNTRL + C`.

<br />

A basic command we run is:

```bash
$ docker run -d --rm -it --name <container name> <container image>
```

1. It uses `-d` to detach from current terminal.
2. It uses `--rm` to remove garbage containers after it is exited.
3. It uses `-it` so we can interract with it if we want.
4. It names it with `--name`

### Logs in Container

We can see the `logs` of our container using `docker logs -f <container name | id>`.

### Pause/Unpause a Container

We pause or unpause a container usning `docker pause <container name | id>` or `docker unpause <container name | id>`.

## Attach a Container to a Terminal

We can attach a terminal using `docker attach <container name | id>`.

### Detach us form STDOUT

if we didn't use the `--no-stdin` flag, we can press `control+p, control+q` to detach us from STDOUT

<br />

# Running Commands in a Container

We run commands in a Container using `docker exec <container name | id>`.

For example we could start a bash session using:

```bash
docker exec -it looper bash
```

<br />

# Basic commands

<table><thead><tr><th >command</th><th >explain</th><th >shorthand</th></tr></thead><tbody><tr><td ><code>docker image ls</code></td><td >Lists all images</td><td ><code>docker images</code></td></tr><tr><td ><code>docker image rm &lt;image&gt;</code></td><td >Removes an image</td><td ><code>docker rmi</code></td></tr><tr><td ><code>docker image pull &lt;image&gt;</code></td><td >Pulls image from a docker registry</td><td ><code>docker pull</code></td></tr><tr><td ><code>docker container ls -a</code></td><td >Lists all containers</td><td ><code>docker ps -a</code></td></tr><tr><td ><code>docker container run &lt;image&gt;</code></td><td >Runs a container from an image</td><td ><code>docker run</code></td></tr><tr><td ><code>docker container rm &lt;container&gt;</code></td><td >Removes a container</td><td ><code>docker rm</code></td></tr><tr><td ><code>docker container stop &lt;container&gt;</code></td><td >Stops a container</td><td ><code>docker stop</code></td></tr><tr><td ><code>docker container exec &lt;container&gt;</code></td><td >Executes a command inside the container&nbsp;</td><td ><code>docker exec</code></td></tr></tbody><tfoot></tfoot><captionF></caption></table>

<br />

## Tags in containers

We can create a tag by typing `docker tag <image name>:<tag> <image name>:<new tag>`

for examle:

```bash
# creates tag noble_numbat from 25.04
docker tag ubuntu:25.04 ubuntu:noble_numbat
```

## Networking

### Basic Concepts

Programs can send messages to URL addresses, a typical URL is structured like:

`http://127.0.0.1:3000`

- **http:** is the `Protocol`
- **127.0.0.1** is the `IP Adress`, this can also be a `hostname`
- **3000** is the port

Programs can be assigned to listen to any available port. If a program is listening for traffic on port 3000, and a message is sent to that port, the program will receive and possibly process it.

### localhost

`localhost` or `127.0.0.1` always refers to the machime or container itself, we could map the port to exchange messages between container and host but by default id we send messages from container to localhost, it would mean we send messages to ourselfs.

## Opening Connections from Outside World to Container

The connection happens in two steps

1. Expose port
   - this means container will know which ports to listen to.
   - we expose ports like this
     ```docker
     # in Dockerfile
     EXPOSE <port>
     ```
2. Publish port
   - this maps the outside ports to the containers ports.
     ```bash
     # in command line
     docker run -p <host-port>:<container-port> <container-name>
     ```

#### \*\* **WARNING** \*\*

Publishing a port like this opens the port to **everyone**, to only open the port from our computer to the application we can specify the **ip** like `-p 127.0.0.1:3456:3000`.

This happens because:

<table><thead><tr><th >short syntax</th><th >translation</th></tr></thead><tbody><tr><td ><code>-p 3456:3000</code></td><td ><code>-p 0.0.0.0:3456:3000</code></td></tr><tr><td ><code>-p 127.0.0.1:3456:3000 </code></td><td ><code>-p 127.0.0.1:3456:3000</code></td></table>

## Publishing Projects

We can bublish images in `https://hub.docker.com/`, if we create an account, we can login using:

```bash
docker login
```

and tag and publish an image with:

```bash
docker tag <image_name> <username>/<repository>

docker push <username>/<repository>
```

# Docker Compose

Docker compose is a tool for managing and building and running multiple containers using a single command:

```bash
docker compose [-f <arg>...] [options] [COMMAND] [ARGS...]
```

a docker compose file has the `.yml` extension and is generally
defined as:

```docker
services:
  <service-name>:
    image: <username>/<repositoryname>
    build: .
    volumes:
      - .:/mydir
    container_name: <container-name>
```

<br />

---

\*\* **IMPORTANT NOTE** \*\*

Keep in mind that the **Tree structure has to be kept**, so `volume` and `image` have to be **leafs** of the `service`!

---

<br />

Here, `build` is used to build an image in the current dir `.` that has the Dockerfile.

and run as `$ docker compose run <service-name> <params>`

# Commands

we can run commands as we did `CMD` in the Dockerfile, just
type:

```docker
  #services:
  # <service-name>
      # image: <image-name>
      command: <command-to-run>
```

** Useful Commands **

restart defines the policy that the platform applies on container termination.

`restart: <"no", always, on-failure, on-failure:number, unless-stopped>`

- `no`: The default restart policy. It does not restart the container under any circumstances.
- `always`: The policy always restarts the container until its removal.
- `on-failure[:max-retries]`: The policy restarts the container if the exit code indicates an error. Optionally, limit the number of restart retries the Docker daemon attempts.
- `unless-stopped`: The policy restarts the container irrespective of the exit code but stops restarting when the service is stopped or removed.

# Exposing Ports

ports can also be exposed by typing:

```docker
  #services:
  # <service-name>
      # image: <image-name>
      ports:
       - <port-in-host>:<port-in-container>
```

it's the same as typing `-p <port-in-host>:<port-in-container>` in docker run. Again **Be aware of tree struncture**.

## Volumes

We can define volumes by specifying them with

```docker
  volumes:
    - <location-in-host>:<location-in-container>
```

- we can list them with `docker volume ls`
- we can delete them with `docker volume prune`

## Ready image

In image we can use an existing one by just putting the image name

```docker
services:
  nginx:
    image: nginx:1.27
  database:
    image: postgres:17
```

## Run, Stop and Remove running Services

```bash
# Run the services
docker compose up

# Stop Services
docker compose down

# Monitor containers
docker compose logs

# List all running Services
docker compose ps
```

## flags

flags can be added after `up`, so we do `docker compose up [flags]`

## Networking in Docker Compose

`Docker network` automatically creates joins between services.

Services in `.yml` files are automatically joined into a network using `DNS` each service is given a name as pecified in the file.

### Manual Define a network

We can manually define a network by define `networks`, we could do it as:

```docker
services:
  db:
    image: postgres:13.2-alpine
    networks:
      - database-network

networks:
  database-network:
    name: database-network

```

external could be defined by using `external`, so we could change:

```docker
networks:
  database-network:
    external: # added external
      name: database-network
```

**By default all services are added to** `default` network, we could change it so that it can connect to external networks **By default**:

```docker
networks:
  default: # added default
    database-network:
      external:
        name: database-network
```

### Scaling

Docker compose also allows scaling, we can scale up using the `--scale` flag. This runs multiple instances of a service specified.

If we specify a port to bind in .yml file, the the scale will fail because all instances will attempt to bind to the specfied port.

To avoid that we can just `not define` it and docker will **automatically choose a free port**.

#### View and use scaled container ports

To view the used ports we can use `docker compose port`, this index each port used. Then to use it we can `curl them`:

```bash
docker compose port --index 1 whoami 8000
  # shows 0.0.0.0:32770

docker compose port --index 2 whoami 8000
  # shows 0.0.0.0:32769

docker compose port --index 3 whoami 8000
  # shows 0.0.0.0:32768

curl 127.0.0.1:32769
  # shows I'm 536e11304357

curl 127.0.0.1:32768
  # shows I'm 1ae20cd990f7
```

** Nginx Config **

To setup Nginx we have to

- get nginx proxy image
- mount `docker.sock` (opens in a new tab) of our host machine (`the socket that is used to communicate with the Docker Daemon`) inside of the container in :ro read-only mode
- use a port

We also have to use `VIRTUAL_HOST` env variable, we can use some `domain` which `all subdomains point to localhost`, like `colasloth.com`.

```docker
services:
  whoami:
    image: jwilder/whoami
    environment:
      - VIRTUAL_HOST=whoami.colasloth.com
  proxy:
    image: jwilder/nginx-proxy
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
    ports:
      - 80:80
```

then we could just serve html files by adding them to the container and using these paths as volumes:

```docker
hello:
  image: nginx:1.19-alpine
  volumes:
    - ./hello.html:/usr/share/nginx/html/index.html:ro
  environment:
    - VIRTUAL_HOST=hello.colasloth.com
world:
  image: nginx:1.19-alpine
  volumes:
    - ./world.html:/usr/share/nginx/html/index.html:ro
  environment:
    - VIRTUAL_HOST=world.colasloth.com
```

## Making sure a service starts first

we can use `depends_on:` instruction by providing a service name to specify we want it to start first:

```docker
redmine:
  image: redmine:5.1-alpine
  environment:
    - REDMINE_DB_POSTGRES=db
    - REDMINE_DB_PASSWORD=example
  ports:
    - 9999:3000
    # db will start first
  depends_on:
    - db
```

# Container Best Practices

## Official Images

We can't trust official images 100%.

Docker does keep some [official images](https://github.com/docker-library/official-images), we can also find them on Dockerhub. Many well-known projects are also maintained under [docker library](https://github.com/docker-library), but some are managed by the organisations.

We always read the README file and track the `Dockerfile` the images are created from. To do so, we can:

```bash
docker image history --no-trunc ubuntu:24.04
```

and check if image history matches with the directives specified in the Dockerfile.

## Deployment Pipelines

We can create deployment pipelines using

1. [Github actions](https://github.com/features/actions)
2. [WatchTower]()

### 1. Github Actions

We can define workflows in the **main.yml** of the **.github/workflows** directory:

```docker
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:  # name of the job
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v2

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1

    - name: Log in to Docker Hub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push Docker image
      uses: docker/build-push-action@v2
      with:
        context: .
        push: true
        tags: ${{ secrets.DOCKER_USERNAME }}/beermapping:latest
```

the `build` in this example is one job that has steps. Each step is a small operation or **_action_** that does part of the whole job.

So the actions are:

1. `actions/checkout@v2` is used to check out the code from the repository
2. `docker/setup-buildx-action@v1` is used to set up the Dockerx build environment
3. `docker/login-action@v1` is used to log in to Docker Hub
4. `docker/build-push-action@v2` is used to build the image and push it to Docker Hub

So after we have pushed the image to dockerhub, somehow we need to see the change and restart the container usning the new image, this is were `watchtower` comes to play.

### WatchTower

Watchtower will pull the source of the image (in this case Docker Hub) for changes in the containers that are running. The container that is running will be updated and automatically restarted when a new version of the image is pushed to Docker Hub. Watchtower respects tags e.g. q container using ubuntu:24.04 will not be updated unless a new version of ubuntu:24.04 is released.

\*\* **Security reminder: Docker Hub accessing our computer** \*\*

Note that now anyone with access to our Docker Hub also has access to our PC through this. If they push a malicious update to our application, Watchtower will happily download and start the updated version.

So this would be the compose file:

```docker
services:
  watchtower:
    image: containrrr/watchtower
    environment:
      -  WATCHTOWER_POLL_INTERVAL=60 <em># Poll every 60 seconds</em>
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    container_name: watchtower
```

One needs to be careful when starting Watchtower with docker compose up, since it will try to update every image running the machine. The [documentation](https://containrrr.dev/watchtower/) describes how this can be prevented.

## Using a non-root user

Because of security concerns, we might want to alter the container's default user. We can achieve this using the `RUN useradd -m appuser` command.

This creates a **user**, then whe can change the user with `USER appuser`. \*\* **this user does not have access rights to the container's file system** \*\*.

After that, **all commands including** `ENTRYPOINT` and `CMD` will be executed by this user.

### Giving permissions

To give permissions to the user we use `RUN chown appuser .` to give permissions for the current directory. \*\* **We must do this while we still executing as `root`, so before the `USER` command** \*\*.

The workflow could be as folows:

```docker
FROM ubuntu:24.04

# ...

WORKDIR /mydir

# create the appuser
RUN useradd -m appuser

# change the owner of current dir to appuser
RUN chown appuser .

# now we can change the user
USER appuser

ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```

## Image Size

Image size is important and can be measured with two ways:

1. Time image takes to be **pushed**
2. Time image takes to be **pulled**

there are a few ways to reduce image size, reducing the number of layers eg. the instructions in the Dockerfile is **NOT** one of them.

### Remove unnecessary dependencies

A good way of reducing the image size is to **remove unnecessary dependencies**.

For example to remove node dependencies we can use:
`rm -rf /var/lib/apt/lists/*`

To remove any packages we dont want we can use `apt-get -y purge`, `apt-get -y autoremove` and `apt-get clean`.

### Use lighter images

We can also reduce image size by using more lightweight images. For example `ubuntu` images are heavier that `alpine` because they provide more features.

### Multi-stage builds

Multi-stage builds are useful when you need some tools just for the build but not for the execution of the image (that is for CMD or ENTRYPOINT). This is an easy way to reduce size in some cases.

To achieve this we make an Image using `FROM` but name it with `AS` keyword. We then write the instructions and use this image name to copy the files from the first stage to the second one with `--from=`. The whole workflow could be described as follows:

```docker
# the  first stage needs to be given a name
FROM ruby:3 AS build-stage
WORKDIR /usr/app

RUN gem install jekyll
RUN jekyll new .
RUN jekyll build

# we will now add a new stage
FROM nginx:1.19-alpine

COPY --from=build-stage /usr/app/_site/ /usr/share/nginx/html
```
