FROM alpine:3.13 AS builder

LABEL Name=app_node Version=0.1.0 Maintainer="Allen Vailliencourt <allenv@goteleport.com>"

RUN mkdir -p /etc/skel
COPY configs/user_logout_config /etc/skel/.cshrc
COPY configs/user_logout_config /etc/skel/.profile
COPY configs/app_motd /etc/motd

RUN set -xe \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssh ufw iptables curl \
    && rm -rf /tmp/* /var/cache/apk/* \
    # host CA & user CA generation
    && ssh-keygen -t ed25519 -f /etc/ssh/app_host_ca -C app_host_ca \
    && ssh-keygen -t ed25519 -f /etc/ssh/app_user_ca -C app_user_ca \
    # gen host key and sign it - will generate a ssh_host_ed25519_key-cert.pub file
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -s /etc/ssh/app_host_ca -I app.example.com -h -n app.example.com,localhost,app,app-node -V +2h /etc/ssh/ssh_host_ed25519_key.pub \
    # gen user key and sign it - will generate a user-key-cert.pub file
    && ssh-keygen -t ed25519 -f /etc/ssh/app-user-key \
    && ssh-keygen -s /etc/ssh/app_user_ca -I app -n appuser,bastion -V +30m /etc/ssh/app-user-key.pub \
    # disable ip6tables as it causes issues in docker
    && sed -i "s/IPV6=yes/IPV6=no/g" /etc/default/ufw
    
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

COPY configs/app_startup.sh app_startup.sh

RUN addgroup -S -g ${GID} ${GROUP} \
    && adduser -D -h ${HOME} -s ${SHELL} -u ${UID} -G ${GROUP} --disabled-password ${USER} \
    && echo "${USER}:${PASSWORD}" | chpasswd \
    && chmod +x app_startup.sh \
    && curl "https://raw.githubusercontent.com/Anupya/dadjoke-cli/master/dadjoke" -o /usr/local/bin/dadjoke \ 
    && chmod +x /usr/local/bin/dadjoke

EXPOSE 2223

# Details on the flags used: https://explainshell.com/explain?cmd=sshd+-D+-e
# The startup script runs the UFW rules and then starts SSHD
CMD ./app_startup.sh