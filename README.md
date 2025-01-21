# GIT-SERVER
Git server with OpenSSH

### Main Files
* `.env` - file containing environment variables
* `Dockerfile` - the main file for building the image
* `entrypoint.sh` - script for creating configurations when the container starts
* `healthcheck.sh` - script for checking the status of the `sshd` service

### Configuration
Configuration is done using the container's environment variables:
* `SSH_PUBLIC_KEYS` - public SSH keys for accessing repositories, separated by commas. A single key can be specified. Running without this variable is allowed if the `authorized_keys` file containing SSH keys is mounted as `authorized_keys:/home/git/.ssh/authorized_keys`.
* `GIT_REPOS_NAME` - list of repositories to be created, separated by commas. A single repository can be specified. This can be left empty, in which case a default repository named `configs` will be created.
* `GIT_REPOS_DIR` - root directory for repositories. Running without this variable is allowed, in which case the directory `/repos` will be created.

### Starting the Server
1. Edit the environment variable file [`.env`](./.env).
2. Start the git-server container:
    ```bash
    docker compose up -d
    ```
    * The `SSH_PUBLIC_KEYS` environment variable takes precedence over the mounted `authorized_keys` file. If both the environment variable and the file are used simultaneously, the file's content will be overwritten by the value of the environment variable.

## Running in a k8s Cluster
### Using Helm
1. Edit the [`helm/values.yaml`](./helm/values.yaml).
2. Deploy the `git-server`:
    * From local files:
        ```bash
        helm upgrade --install git-server helm/
        # helm upgrade --install git-server helm/ --set ssh_public_keys="$(cat ~/.ssh/id_rsa.pub)"
        ```
    * From a Helm repository:
        ```bash
        helm install git oci://ghcr.io/nmparfyonov/git-server/git-server --version 0.1.1 -f helm/values.yaml
        # helm install git oci://ghcr.io/nmparfyonov/git-server/git-server --version 0.1.1 --set ssh_public_keys="$(cat ~/.ssh/id_rsa.pub)"
        ```

### k8s Manifests
Manifests can be generated from the Helm chart if needed:
```bash
helm template git helm/ > manifests.yaml
```