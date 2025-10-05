# bootc-centos-k3s-server
Project for Centos Stream 10 k3s cluster.

## Build Instructions

This project uses multi-stage builds and environment variables for flexible configuration. Secrets are handled securely using Podman BuildKit features.

### 1. Prepare Environment Files

- `k3s.env`: Contains all non-secret K3s configuration variables.
- `k3s-token-secret.env`: Contains only the K3S_TOKEN value.

### 2. Load Variables and Prepare Secret

```sh
set -a
source k3s.env
set +a
source k3s-token-secret.env
echo "$K3S_TOKEN" > k3s_token.txt
```

### 3. Build the Image

```sh
podman build \
	--secret id=K3S_TOKEN,src=k3s_token.txt \
	--build-arg INSTALL_K3S_SKIP_DOWNLOAD="$INSTALL_K3S_SKIP_DOWNLOAD" \
	--build-arg INSTALL_K3S_SYMLINK="$INSTALL_K3S_SYMLINK" \
	--build-arg INSTALL_K3S_SKIP_ENABLE="$INSTALL_K3S_SKIP_ENABLE" \
	--build-arg INSTALL_K3S_SKIP_START="$INSTALL_K3S_SKIP_START" \
	--build-arg INSTALL_K3S_VERSION="$INSTALL_K3S_VERSION" \
	--build-arg INSTALL_K3S_BIN_DIR="$INSTALL_K3S_BIN_DIR" \
	--build-arg INSTALL_K3S_BIN_DIR_READ_ONLY="$INSTALL_K3S_BIN_DIR_READ_ONLY" \
	--build-arg INSTALL_K3S_SYSTEMD_DIR="$INSTALL_K3S_SYSTEMD_DIR" \
	--build-arg INSTALL_K3S_EXEC="$INSTALL_K3S_EXEC" \
	--build-arg INSTALL_K3S_NAME="$INSTALL_K3S_NAME" \
	--build-arg INSTALL_K3S_TYPE="$INSTALL_K3S_TYPE" \
	--build-arg INSTALL_K3S_SELINUX_WARN="$INSTALL_K3S_SELINUX_WARN" \
	--build-arg INSTALL_K3S_SKIP_SELINUX_RPM="$INSTALL_K3S_SKIP_SELINUX_RPM" \
	--build-arg INSTALL_K3S_CHANNEL_URL="$INSTALL_K3S_CHANNEL_URL" \
	--build-arg INSTALL_K3S_CHANNEL="$INSTALL_K3S_CHANNEL" \
	--build-arg K3S_SELINUX="$K3S_SELINUX" \
	-t k3s-server .
```

### Summary

- All configuration values from `k3s.env` are passed as build arguments and set as environment variables in the image.
- The K3S token is handled securely as a secret.
- You can automate the build-arg part with a shell loop if you add/remove variables often.
