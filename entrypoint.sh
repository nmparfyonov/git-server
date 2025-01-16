#!/bin/bash

# Check ssh keys
if [ -z "$SSH_PUBLIC_KEYS" ] && [ ! "$(grep -v '^[[:space:]]*$' $USER_GIT_HOME/.ssh/authorized_keys)" ]; then
    echo -e "Error: SSH_PUBLIC_KEYS environment variable is not set\nError: \"$USER_GIT_HOME/.ssh/authorized_keys\" file is emply."
    echo -e "To grant SSH access:\n\
    - Provide a comma-separated list of public keys using the SSH_PUBLIC_KEYS environment variable\n\
    - Mount non-empty \"authorized_keys\" file to path \"$USER_GIT_HOME/.ssh/authorized_keys\"\n"
    exit 1
fi

# Add ssh keys from env if SSH_PUBLIC_KEYS is set
if [ -n "$SSH_PUBLIC_KEYS" ]; then
    echo "$SSH_PUBLIC_KEYS" | tr ',' '\n' > /home/git/.ssh/authorized_keys
    chmod 600 $USER_GIT_HOME/.ssh/authorized_keys
    chown git:git $USER_GIT_HOME/.ssh/authorized_keys
fi

# Print available ssh identities
echo -e "SSH identities:\n$(awk '!/^#/ && NF >= 3 {print "    - " $3}' $USER_GIT_HOME/.ssh/authorized_keys)\n"

# Check git repositories directory exists
if [ ! -d "$GIT_REPOS_DIR" ]; then
    mkdir -p $(dirname $GIT_REPOS_DIR)
fi

# Check git repositories env GIT_REPOS_NAME is present or set default value
if [ -z "$GIT_REPOS_NAME" ]; then
    GIT_REPOS_NAME="configs"
    echo "GIT_REPOS_NAME is not set. Using default: $GIT_REPOS_NAME.git"
fi

# Loop to create git repositories
IFS=',' read -ra REPO <<< "$GIT_REPOS_NAME"
for repo in "${REPO[@]}"; do
    if [ ! -d "$GIT_REPOS_DIR/${repo,,}.git" ]; then
        echo "Git repository \"${repo,,}\" doesn't exist. Creating repository"
        mkdir -p $(dirname $GIT_REPOS_DIR/${repo,,}.git)
        git init --bare $GIT_REPOS_DIR/${repo,,}.git
        chown -R git:git $GIT_REPOS_DIR/${repo,,}.git
    else
        echo "Git repo \"${repo,,}\" already exists."
    fi
done

# Print available git repositories with clone command
echo -e "Available git repositories clone command:\n"
mapfile -t DIRS < <(find "$GIT_REPOS_DIR" -maxdepth 1 -type d -name '*.git')
for dir in "${DIRS[@]}"; do
    echo -e "    git clone ssh://git@$(hostname -I | sed 's/ //g')$dir"
done

# Print hint how to avoid ssh host key checking
echo -e "\nUse environment variable GIT_SSH_COMMAND on your host to avoid host key checking:\n\n\
    export GIT_SSH_COMMAND=\"ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no\"\n"

# Start sshd
/usr/sbin/sshd -D -e