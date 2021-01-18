# Using Alpine latest but you can always tag a specific version. Recommended to stick with a named version as sometimes a latest tag can break something.
# todo: use AS builder and FROM step builds
FROM alpine:latest AS builder

LABEL Name=bastion_node Version=0.0.1 Maintainer="Allen Vailliencourt <allenv@outlook.com>"

# creating skelton directory and copying templated files over
RUN mkdir -p /etc/skel
COPY configs/user_logout_config /etc/skel/.cshrc
COPY configs/user_logout_config /etc/skel/.profile
COPY configs/bastion_motd /etc/motd

# adding alpine packages and generating ssh key for ed25519 (keys are temp until CA is built)
RUN set -xe \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssh \
    && rm -rf /tmp/* /var/cache/apk/* \
    && /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# copying over customized sshd_config on build
COPY configs/sshd_config /etc/ssh/sshd_config

FROM builder as bastion

ARG HOME=/opt/bastion
ARG SHELL=/bin/ash
ARG USER=bastion
ARG GROUP=bastion
ARG PASSWORD=B4st1oN!
ARG UID=1337
ARG GID=1337

# creating bastion user
RUN addgroup -S -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -s ${SHELL} -u ${UID} -G ${GROUP} ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd

EXPOSE 22

# Details on the flags used: https://explainshell.com/explain?cmd=sshd+-D+-e
CMD ["/usr/sbin/sshd","-D", "-e"]