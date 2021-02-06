# Use this Docker image to create a statically linked Linux version of vcpkg.
#
# These instructions assume you are familiar with Docker, or at least
# you have used it before. They also assume that Docker is installed
# and functional in your workstation. You may need to use `sudo docker`
# if your account does not have permissions to invoke the docker
# commands directly.
#
# Run this command to create a Docker image, this will download all
# the necessary development tools and then compile the vcpkg tool:
#
# $ docker build -t vcpkg-bin -f azure-pipelines/create-linux-binary.Dockerfile .
#
# Now extract the binary from the Docker image:
#
# $ docker run --user $UID --rm --volume /var/tmp:/v vcpkg-bin:latest cp /b/vcpkg /v
#
# The vcpkg tool executable will be in /var/tmp/vcpkg
#

ARG DISTRO_VERSION=3.13.1
FROM alpine:${DISTRO_VERSION} AS base

RUN apk update && \
    apk add \
        build-base \
        cmake \
        curl \
        curl-dev \
        curl-static \
        git \
        gcc \
        g++ \
        nghttp2-static \
        ninja \
        openssl-dev \
        openssl-libs-static \
        tar \
        zlib-static

COPY . /s
RUN cmake -GNinja -S /s -B /b -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXE_LINKER_FLAGS="-static" -DBUILD_TESTING=OFF
RUN cmake --build /b
RUN strip /b/vcpkg
