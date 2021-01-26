# Teleport ~ Bastion Exercise

## Introduction

Welcome to the Teleport Bastion Exercise. The purpose of this repository is to allow a user to access an isolated node using a bastion or proxy host.

We will be leveraging Docker containers for both the proxy and application nodes.

Contact Allen Vailliencourt <allenv@outlook.com> for any questions/comments.

***

## Instructions

### Pre-requisites
- Docker & Docker Compose installed locally
- Shell/Terminal access
- Potential `root` priviledges (if needed, depending on your system Docker may or may not require root priviledge)
- Internet access to pull upstream images

### Directory Layout
* `configs` - Stores basic configuration files and templates that will be copied to the container on build time

    * `app_issue` - Optional SSH MOTD
    * `bastion_issue` - Optional SSH MOTD
    * `app.motd` - Simple MOTD file for app node
    * `bastion.motd` - Simple MOTD file for bastion node (not really used as users cannot SSH into the bastion node)
    * `app_sshd_config` - SSHD configuration file for app node
    * `bastion_sshd_config` - SSHD configuration file for bastion node
    * `app_startup.sh` - This sets and starts the UFW firewall rules and then the SSHD service.
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
2. Open a terminal/shell and `cd` into the repository's main folder (`teleport-bastion-exercise` typically).
3. Run `docker-compose build --build-arg PASSWORD=<PASSWORD>` - this will take a few minutes to build out the two containers. Use the `--build-arg` to input a user password at build time. It can be anything. The password is just for the `appuser` and `bastion` users when initially created. SSH doesn't like users with blank passwords in `/etc/shadow` (that I've found).

    **note:** With the recent changes to the public Docker hub, you might have to login with your Docker username/password in order to download upstream images for the build.
   
4. Run `docker-compose up -d` to start the containers once the build completes. The `-d` flag detaches and runs the containers in the background. You can run a `docker ps` or `docker-compose ps` to see the status of the running containers.
5. Run `chmod +x copy_keys.sh` to make the shell script executable (needed for next step).
6. Run `./copy_keys.sh`. This bash script will copy the certs, pub keys, set up a custom config file, and modify your `~/.ssh/known_hosts` file. **Note:** if you are `root` you might have to manually create the `/root/.ssh/` directory so that the script can write out the `config` file. Dig into the script for details on what it does if you are curious. The files will be added to your `/tmp/ssh_files` folder. There is no error checking in the bash script for this demo. In a production environment you would want your bash script to be a little more robust.
7. Run `ssh -F /tmp/ssh_files/config app-node`. After a few seconds your terminal should drop into the `app_node`. You can also run `ssh -F /tmp/ssh_files/config -J bastion-node app-node` as another option. What this command does is leverage your `config` file to ProxyJump from the `bastion-node` to the `app-node`. If you want to see some verbose logging you can put in the `-vv` flag in the ssh command.
9. Congrats! You have successfully connected to a docker container via a bastion host leveraging SSH certificates!
10. Type in `exit` to disconnect and `docker-compose down` to stop the running containers.

### Tested On

* OSX - Catalina, 10.15.7 - docker version 19.03.13
* Vagrant - Ubuntu 20.04 - docker verion 20.10.2

### Credits

* Much of the inspiration came from multiple open-source repositories, blog posts, and gists of various ways of tackling this project. Google & StackOverflow are your friends. :)