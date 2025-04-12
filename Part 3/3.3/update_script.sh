#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <github-repository-url> <dockerhub-repository>"
  echo "Example: $0 https://github.com/username/repo.git username/image_name"
  exit 1
fi

GITHUB_REPO_URL=$1
DOCKER_REPO=$2
REPO_NAME=$(basename "$GITHUB_REPO_URL" .git)

echo "Cloning repository: $GITHUB_REPO_URL..."
git clone "$GITHUB_REPO_URL"

cd "$REPO_NAME"

echo "Building Docker image: $DOCKER_REPO..."
docker build -t "$DOCKER_REPO" .

echo "Pushing Docker image to Docker Hub..."
docker push "$DOCKER_REPO"

echo "Cleaning up..."
cd ..
rm -rf "$REPO_NAME"

echo "Docker image $DOCKER_REPO has been pushed to Docker Hub!"
