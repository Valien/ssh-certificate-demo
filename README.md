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

**NOTE:** This is a work-in-progress. The POC works but there are some missing pieces that I'm still working on fixing.

1. Git clone this repo via HTTPS, SSH, or GH CLI.
2. Open a terminal and `cd` into the main folder.
3. Run `docker-compose build` - this will take a few minutes to build out the 2 containers.
4. After build completes run `docker-compose up -d` to start the containers and run them in the background. You can run a `docker ps` to see that they are running.
5. Run `chmod +x copy_keys.sh` to make the shell script executable (needed for next step)
6. Run `./copy_keys.sh` - this will copy the certs and pub keys from both the Bastion and App nodes. This will also append some ssh configs to your `~/.ssh/config` file. See the details in the `copy_keys.sh` file.
7. Run `ssh -J bastion-node app-node` and if this is your first time connecting you will be prompted to accept the `ED25519 key fingerprint...` Go ahead and type in `yes`. You'll do this for the `bastion-node` and the `app-node`.
8. If all succeeded and you are authenticated then you should be dropped into the `app-node` terminal. 
9. Congrats! You have successfully connected to a docker container via a bastion host!
10. Type in `exit` to disconnect and `docker-compose down` to stop the running containers.

### TODO & ISSUES

1. Continued testing.
2. Security and hardening (as best as possible)
3. Look into the docker-compose networks for isolation/privacy.
4. Right now a user can target the app-node but cannot login (at least to my knowledge and testing). Planning on locking this down some more.
5. Users can also ssh to the bastion-node right now. Still determining if this is a wanted case or to lock it out (see Roman's comments on last PR around this question)

### CREDITS

* Much of the inspiration came from multiple open-source repositories, blog posts, and gists of various ways of tackling this project. Google & StackOverflow are your friends. :)