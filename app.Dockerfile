FROM alpine:3.13 AS builder

LABEL Name=app_node Version=0.1.0 Maintainer="Allen Vailliencourt <allenv@outlook.com>"

RUN mkdir -p /etc/skel
COPY configs/user_logout_config /etc/skel/.cshrc
COPY configs/user_logout_config /etc/skel/.profile
COPY configs/app_motd /etc/motd
# the below helps lock down the app-node by only allowing SSH from the bastion-node
COPY configs/hosts.allow /etc
COPY configs/hosts.deny /etc

RUN set -xe \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssh \
    && rm -rf /tmp/* /var/cache/apk/* \
    && /usr/bin/ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# copying over customized sshd_config on build
COPY configs/app_sshd_config /etc/ssh/sshd_config

FROM builder as bastion

ARG HOME=/opt/appuser
ARG SHELL=/bin/ash
ARG USER=appuser
ARG GROUP=appuser
ARG PASSWORD
ARG UID=1337
ARG GID=1337

WORKDIR /app_ssh

RUN addgroup -S -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -s ${SHELL} -u ${UID} -G ${GROUP} --disabled-password ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && ssh-keygen -t ed25519 -f /etc/ssh/ca_key -C ca -N "" \
    && ssh-keygen -t ed25519 -f ${USER} -C ${USER} -N "" \
    && ssh-keygen -s /etc/ssh/ca_key -V +52w -n ${USER} -I ${USER}-key1 -z 1 ${USER}.pub
    
EXPOSE 2223

# Details on the flags used: https://explainshell.com/explain?cmd=sshd+-D+-e
CMD ["/usr/sbin/sshd","-D", "-e"]