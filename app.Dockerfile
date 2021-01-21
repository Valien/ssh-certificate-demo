FROM alpine:3.13 AS builder

LABEL Name=app_node Version=0.1.0 Maintainer="Allen Vailliencourt <allenv@outlook.com>"

RUN mkdir -p /etc/skel
COPY configs/user_logout_config /etc/skel/.cshrc
COPY configs/user_logout_config /etc/skel/.profile
COPY configs/app_motd /etc/motd
# the below helps lock down the app-node by only allowing SSH from the bastion-node
COPY configs/hosts.allow /etc
COPY configs/hosts.deny /etc
#COPY configs/app_issue /etc/issue

RUN set -xe \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssh \
    && rm -rf /tmp/* /var/cache/apk/* \
    # host CA & user CA generation
    && ssh-keygen -t ed25519 -f /etc/ssh/app_host_ca -C app_host_ca \
    && ssh-keygen -t ed25519 -f /etc/ssh/app_user_ca -C app_user_ca \
    # gen host key and sign it - will generate a ssh_host_ed25519_key-cert.pub file
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -s /etc/ssh/app_host_ca -I app.example.com -h -n app.example.com,localhost,app,app-node -V +60d /etc/ssh/ssh_host_ed25519_key.pub \
    # gen user key and sign it - will generate a user-key-cert.pub file
    && ssh-keygen -t ed25519 -f /etc/ssh/app-user-key \
    && ssh-keygen -s /etc/ssh/app_user_ca -I app -n appuser,bastion -V +30d /etc/ssh/app-user-key.pub

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
    && echo "${USER}:${PASSWORD}" | chpasswd
    
EXPOSE 2223

# Details on the flags used: https://explainshell.com/explain?cmd=sshd+-D+-e
CMD ["/usr/sbin/sshd","-D", "-e"]