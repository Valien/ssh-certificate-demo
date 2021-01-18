# Teleport ~ Bastion Exercise

## Introduction

Welcome to the Teleport Bastion Exercise. The purpose of this repository is to allow a user to access an isolated node using a bastion or proxy host.

We will be leveraging Docker containers for both the proxy and application nodes.

Contact Allen Vailliencourt <allenv@outlook.com> for any questions/comments.

***

## Instructions

### Pre-requisites
- Docker installed locally
- Shell/Terminal access
- Internet access to pull upstream images

### Directory layout
* `templates` - Stores basic configuration files and templates that will be copied to the container on build time

    * `motd` - Simple MOTD file
    * `sshd_config` - Modified SSH configuration file
    * `user_cshrc_config` - Default shell settings
    * `user_logout_config` - Default `.profile` settings

* `app.Dockerfile` - Dockerfile for the Application node
* `bastion.Dockerfile` - Dockerfile for the Bastion node
* `docker-compose.yml` - Docker Compose file to start all containers -- _WIP_
* `Dockerfile` - Generic Dockerfile for testing. Will be removed
* `LICENSE` - Standard Apache License
* `README.md` - What you're reading now! :)

### Running the Bastion Exercise

**NOTE:** This is a work-in-progress. Using SSH keys for concept at the moment and basic SSH connectivity. Probably will break in some unexpected fashion.

1. From a terminal launch the following: `docker build -t bastion:0.1 -f bastion.Dockerfile .` Your system should start to download the necessary files and build out the container locally.
2. Once the build is completed you can run the Bastion node using the following command: `docker run -d -p 2222:2222 bastion:0.1`
3. You can then SSH into the Bastion node with the following command: `ssh bastion@localhost -p 2222` The password is `B4st1oN1`. Once logged in you'll be dropped into a local terminal.
4. Once you exit the shell you can stop the running container by name (if you included that in your run command) or via the docker uid.

### TODO

1. Build app node
2. Bring both under the `docker-compose.yml` file
3. Test connectivity and leverage SSL certificates vs Keys are being used right now.
4. More stuff I'm forgetting at the moment.
5. Secure everything as best as possible.
