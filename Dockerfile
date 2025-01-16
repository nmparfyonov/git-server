FROM docker.io/ubuntu:22.04

LABEL maintainer="Mikita Parfionau <nikita.parfyonov.ai@gmail.com>" \
    version="0.1.0" \
    description="Git server with OpenSSH"

ENV DEBIAN_FRONTEND=noninteractive \
    USER_GIT_HOME=/home/git \
    GIT_REPOS_DIR=/repos

COPY . .

RUN chmod +x /entrypoint.sh /healthcheck.sh && \
    apt-get update && \
    apt-get install -y --no-install-recommends git openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd && \
    chmod 0755 /var/run/sshd && \
    useradd -m -d $USER_GIT_HOME -s /usr/bin/git-shell git && \
    mkdir -p $USER_GIT_HOME/.ssh && \
    chmod 0700 $USER_GIT_HOME/.ssh && \
    touch $USER_GIT_HOME/.ssh/authorized_keys && \
    chown -R git:git $USER_GIT_HOME/.ssh

ENTRYPOINT ["/entrypoint.sh"]
