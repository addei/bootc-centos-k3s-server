FROM quay.io/centos-bootc/centos-bootc:stream10 AS base

# Remove RHUI packages if present
RUN dnf remove -y subscription-manager

# Install base packages
RUN dnf install cloud-init qemu-guest-agent \
    container-selinux cockpit-system cockpit-ws cockpit-files cockpit-networkmanager cockpit-ostree cockpit-selinux cockpit-storaged cockpit-podman \
    nfs-utils libnfsidmap sssd-nfs-idmap \
    -y

# Clean up DNF cache to reduce image size
RUN dnf clean packages

# Enable the bootc-fetch-apply-updates timer for OS automatic updates
RUN systemctl enable bootc-fetch-apply-updates.timer

# Enable the podman-auto-update timer for automatic container updates
RUN systemctl enable podman-auto-update.timer

# Enable Cockpit
RUN systemctl enable cockpit.socket

# Lint the containerfile
RUN bootc container lint

FROM base AS k3s-server

# Install SElinux packages for k3s
RUN dnf install -y https://rpm.rancher.io/k3s/stable/common/centos/9/noarch/

# Declare build arguments for all .env variables
ARG INSTALL_K3S_SKIP_DOWNLOAD
ARG INSTALL_K3S_SYMLINK
ARG INSTALL_K3S_SKIP_ENABLE
ARG INSTALL_K3S_SKIP_START
ARG INSTALL_K3S_VERSION
ARG INSTALL_K3S_BIN_DIR
ARG INSTALL_K3S_BIN_DIR_READ_ONLY
ARG INSTALL_K3S_SYSTEMD_DIR
ARG INSTALL_K3S_EXEC
ARG INSTALL_K3S_NAME
ARG INSTALL_K3S_TYPE
ARG INSTALL_K3S_SELINUX_WARN
ARG INSTALL_K3S_SKIP_SELINUX_RPM
ARG INSTALL_K3S_CHANNEL_URL
ARG INSTALL_K3S_CHANNEL
ARG K3S_SELINUX

# Set environment variables from build args
ENV INSTALL_K3S_SKIP_DOWNLOAD=${INSTALL_K3S_SKIP_DOWNLOAD} \
    INSTALL_K3S_SYMLINK=${INSTALL_K3S_SYMLINK} \
    INSTALL_K3S_SKIP_ENABLE=${INSTALL_K3S_SKIP_ENABLE} \
    INSTALL_K3S_SKIP_START=${INSTALL_K3S_SKIP_START} \
    INSTALL_K3S_VERSION=${INSTALL_K3S_VERSION} \
    INSTALL_K3S_BIN_DIR=${INSTALL_K3S_BIN_DIR} \
    INSTALL_K3S_BIN_DIR_READ_ONLY=${INSTALL_K3S_BIN_DIR_READ_ONLY} \
    INSTALL_K3S_SYSTEMD_DIR=${INSTALL_K3S_SYSTEMD_DIR} \
    INSTALL_K3S_EXEC=${INSTALL_K3S_EXEC} \
    INSTALL_K3S_NAME=${INSTALL_K3S_NAME} \
    INSTALL_K3S_TYPE=${INSTALL_K3S_TYPE} \
    INSTALL_K3S_SELINUX_WARN=${INSTALL_K3S_SELINUX_WARN} \
    INSTALL_K3S_SKIP_SELINUX_RPM=${INSTALL_K3S_SKIP_SELINUX_RPM} \
    INSTALL_K3S_CHANNEL_URL=${INSTALL_K3S_CHANNEL_URL} \
    INSTALL_K3S_CHANNEL=${INSTALL_K3S_CHANNEL} \
    K3S_SELINUX=${K3S_SELINUX}

# Pass the predefined K3S Token as a secret from CICD Variables
RUN --mount=type=secret,id=K3S_TOKEN K3S_TOKEN=$(cat /run/secrets/K3S_TOKEN) curl -sfL https://get.k3s.io | sh -
RUN systemctl enable k3s.service
RUN bootc container lint
