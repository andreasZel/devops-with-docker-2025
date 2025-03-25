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

`localhost` ot `127.0.0.1` always refers to the machime or container itself, we could map the port to exchange messages between container and host but by default id we send messages from container to localhost, it would mean we send messages to ourselfs.

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

## Volumes

We can define volumes by specifying them with

```docker
  volumes:
    - <location-in-host>:<location-in-container>
```

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
