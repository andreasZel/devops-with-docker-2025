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

we can run a container using an existing image by
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
