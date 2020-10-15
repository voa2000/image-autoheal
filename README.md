# base-image-autoheal
### Purpose
This repository contains Autoheal container image.

### How to use it?
The simplest way to use autoheal is running a container with the following parameters

        docker build -t autoheal .
        
        docker run -d \
            -e AUTOHEAL_CONTAINER_LABEL=all \
            -v /var/run/docker.sock:/var/run/docker.sock \
            autoheal
