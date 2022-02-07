NAME="$(basename $PWD)"-$RANDOM

echo "Starting container - $NAME"
docker run -ti --rm \
    -v "$(pwd)"/.config:/root/.config \
    -v "$(pwd)"/.ssh:/root/.ssh \
    -v "$(pwd)":/work \
    -w /work \
    --name $NAME \
    gcp-devops
