FROM ubuntu:latest
RUN apt-get update && apt-get install -y git sudo
RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN sudo git clone https://github.com/thomaas/LibreLink-xDrip-Patch 
WORKDIR /LibreLink-xDrip-Patch
RUN ./install-apt-dependencies.sh
RUN ./download.sh
RUN ./patch.sh