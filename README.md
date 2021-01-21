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
* `configs` - Stores basic configuration files and templates that will be copied to the container on build time

    * `app_issue` - Optional SSH MOTD
    * `bastion_issue` - Optional SSH MOTD
    * `app.motd` - Simple MOTD file for app node
    * `bastion.motd` - Simple MOTD file for bastion node (not really used as users cannot SSH into the bastion node)
    * `app_sshd_config` - SSHD configuration file for app node
    * `bastion_sshd_config` - SSHD configuration file for bastion node
    * `hosts.allow` - Only allow certain hosts to SSH to app node
    * `hosts.deny` - Deny file for app node
    * `sshd_config` - Default SSHD config (not used)
    * `user_cshrc_config` - Default shell settings
    * `user_logout_config` - Default `.profile` settings

* `app.Dockerfile` - Dockerfile for the Application node
* `bastion.Dockerfile` - Dockerfile for the Bastion node
* `docker-compose.yml` - Docker Compose file to start all containers
* `copy_keys.sh` - Bash script to copy SSL certificates and keys to local system
* `LICENSE` - Standard Apache License
* `README.md` - What you're reading now! :)
* `.dockerignore` & `.gitignore` - Standard ignore files

### Running the Bastion Exercise

1. Git clone this repo via HTTPS, SSH, or GH CLI.
2. Open a terminal and `cd` into the main folder.
3. Run `docker-compose build --build-arg=<PASSWORD>` - this will take a few minutes to build out the 2 containers. Use the `--build-arg` to input a user password at build time. It can be anything.
4. After build completes run `docker-compose up -d` to start the containers and run them in the background. You can run a `docker ps` or `docker-compose ps` to see that they are running.
5. Run `chmod +x copy_keys.sh` to make the shell script executable (needed for next step)
6. Run `./copy_keys.sh` - this will copy the certs and pub keys from both the Bastion and App nodes. This will also create a `config` file for your SSH session in the `/tmp/ssh_files` folder. See the details in the `copy_keys.sh` file.
7. Run `ssh -F /tmp/ssh_files/config -J bastion-node app-node` after a few seconds your terminal should drop into the `app_node`. You can also run `ssh -F /tmp/ssh_files/config app-node` as it will automatically ProxyJump you through the `bastion-node`.
9. Congrats! You have successfully connected to a docker container via a bastion host leveraging SSH certificates!
10. Type in `exit` to disconnect and `docker-compose down` to stop the running containers.

### TESTED ON

* OSX - Catalina, 10.15.7 - docker version 19.03.13
* Vagrant - Ubuntu 20.04 - docker verion 20.10.2

### CREDITS

* Much of the inspiration came from multiple open-source repositories, blog posts, and gists of various ways of tackling this project. Google & StackOverflow are your friends. :)