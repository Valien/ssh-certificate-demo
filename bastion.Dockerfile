FROM alpine:3.13 AS builder

LABEL Name=dockerbastion Version=0.1.0 Maintainer="Allen Vailliencourt <allenv@outlook.com>"

RUN mkdir -p /etc/skel
COPY configs/user_logout_config /etc/skel/.cshrc
COPY configs/user_logout_config /etc/skel/.profile
COPY configs/bastion_motd /etc/motd
#COPY configs/bastion_issue /etc/issue

RUN set -xe \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssh \
    && rm -rf /tmp/* /var/cache/apk/* \
    # host & user CA generation
    && ssh-keygen -t ed25519 -f /etc/ssh/bastion_host_ca -C bastion_host_ca \
    && ssh-keygen -t ed25519 -f /etc/ssh/bastion_user_ca -C bastion_user_ca \
    # gen host key and cert- will generate a ssh_host_ed25519_key-cert.pub file
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -s /etc/ssh/bastion_host_ca -I bastion.example.com -h -n bastion.example.com,localhost,bastion -V +60d /etc/ssh/ssh_host_ed25519_key.pub \
    # gen user key and sign it - will generate a user-key-cert.pub file
    && ssh-keygen -t ed25519 -f /etc/ssh/bastion-user-key \
    && ssh-keygen -s /etc/ssh/bastion_user_ca -I bastion -n bastion -V +30d /etc/ssh/bastion-user-key.pub
    
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
    && echo "${USER}:${PASSWORD}" | chpasswd  
    # key pair for signing
    #&& ssh-keygen -t ed25519 -f /etc/ssh/ca_key -C ca -N "" \ 
    #&& cp /etc/ssh/ca_key.pub /bastion_ssh/ \
    # create user cert
    #&& ssh-keygen -t ed25519 -f /etc/ssh/${USER}-user -C ${USER} -N "" \
    #&& ssh-keygen -s /etc/ssh/ca_key -V +30d -n ${USER} -I ${USER}-key1 -z 1 /etc/ssh/${USER}-user.pub \
    # creating host certificate
    #&& ssh-keygen -t ed25519 -f /etc/ssh/${USER}-node -C ${USER}-node -N "" \
    #&& ssh-keygen -s /etc/ssh/ca_key -V +60d -h -n bastion,bastion.example.com,localhost -I bastion-node -z 1 /etc/ssh/${USER}-node.pub
    #&& cp ${USER}-node-cert.pub /etc/ssh/
    
EXPOSE 2222

# Details on the flags used: https://explainshell.com/explain?cmd=sshd+-D+-e
CMD ["/usr/sbin/sshd","-D", "-e"]