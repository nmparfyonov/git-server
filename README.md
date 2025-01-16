# GIT-SERVER
Git server with OpenSSH
## Helm install command
```bash
helm install git oci://ghcr.io/nmparfyonov/git-server/git-server --version 0.1.0 --set ssh_public_keys="$(cat ~/.ssh/id_ed25519.pub)"
```