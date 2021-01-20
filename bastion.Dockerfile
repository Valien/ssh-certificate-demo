FROM alpine:3.13 AS builder

LABEL Name=dockerbastion Version=0.1.0 Maintainer="Allen Vailliencourt <allenv@outlook.com>"

RUN mkdir -p /etc/skel
COPY configs/user_logout_config /etc/skel/.cshrc
COPY configs/user_logout_config /etc/skel/.profile
COPY configs/bastion_motd /etc/motd

RUN set -xe \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssh \
    && rm -rf /tmp/* /var/cache/apk/* \
    && /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# copying over customized sshd_config on build
COPY configs/bastion_sshd_config /etc/ssh/sshd_config

FROM builder as bastion

ARG HOME=/opt/bastion
ARG SHELL=/bin/ash
ARG USER=bastion
ARG GROUP=bastion
ARG PASSWORD
ARG UID=1337
ARG GID=1337

WORKDIR /bastion_ssh

RUN addgroup -S -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -s ${SHELL} -u ${UID} -G ${GROUP} ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && ssh-keygen -t ed25519 -f /etc/ssh/ca_key -C ca -N "" \
    && ssh-keygen -t ed25519 -f ${USER} -C ${USER} -N "" \
    && ssh-keygen -s /etc/ssh/ca_key -V +52w -n ${USER} -I ${USER}-key1 -z 1 ${USER}.pub
    
EXPOSE 2222

# Details on the flags used: https://explainshell.com/explain?cmd=sshd+-D+-e
CMD ["/usr/sbin/sshd","-D", "-e"]