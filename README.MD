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

### Container

Containers are `isolated environments` in the host machine that only contain what is required for the application. We can **start**, **stop** and **interact with eachother or the host machine** via `TCP/UDP`.

we can `list` all containers with:

```bash
docker containers ls -a

# or

docker ps -a
```

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

We can run containers in the current terminal, blocking any
input or use the `-d` flag to run it as `detatched`, meaning it will run in the background:

```bash
docker run <container_id>

# or in the background

docker run -d <container_id>
```

# Basic commands

<table><thead><tr><th >command</th><th >explain</th><th >shorthand</th></tr></thead><tbody><tr><td ><code>docker image ls</code></td><td >Lists all images</td><td ><code>docker images</code></td></tr><tr><td ><code>docker image rm &lt;image&gt;</code></td><td >Removes an image</td><td ><code>docker rmi</code></td></tr><tr><td ><code>docker image pull &lt;image&gt;</code></td><td >Pulls image from a docker registry</td><td ><code>docker pull</code></td></tr><tr><td ><code>docker container ls -a</code></td><td >Lists all containers</td><td ><code>docker ps -a</code></td></tr><tr><td ><code>docker container run &lt;image&gt;</code></td><td >Runs a container from an image</td><td ><code>docker run</code></td></tr><tr><td ><code>docker container rm &lt;container&gt;</code></td><td >Removes a container</td><td ><code>docker rm</code></td></tr><tr><td ><code>docker container stop &lt;container&gt;</code></td><td >Stops a container</td><td ><code>docker stop</code></td></tr><tr><td ><code>docker container exec &lt;container&gt;</code></td><td >Executes a command inside the container&nbsp;</td><td ><code>docker exec</code></td></tr></tbody><tfoot></tfoot><captionF></caption></table>
