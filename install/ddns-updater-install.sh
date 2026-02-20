#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: pxslip
# License: MIT | https://github.com/pxslip/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/qdm12/ddns-updater

# DDNS Updater Install Script

# Import Functions and Setup
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# =============================================================================
# APPLICATION INSTALL
# =============================================================================
msg_info "Setting up $APP"
fetch_and_deploy_gh_release "ddns-updater" "qdm12/ddns-updater" "singlefile" "latest" "/opt/ddns-updater" "ddns-updater_*_linux_amd64"

# =============================================================================
# CONFIGURATION
# =============================================================================
mkdir -p /opt/ddns-updater/data
cat <<EOF >/opt/ddns-updater/data/config.json
{
    "settings": [
        {
            "provider": "",
        }
    ]
}
EOF

msg_ok "Finished setting up $APP"

# =============================================================================
# SERVICE CREATION
# =============================================================================
msg_info "Creating $APP Service"
cat <<EOF >/etc/systemd/system/ddns-updater.service
[Unit]
Description=ddns-updater
After=network.target

[Service]
ExecStart=/opt/ddns-updater/ddns-updater
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now ddns-updater.service
msg_ok "Created $APP Service"

# =============================================================================
# CLEANUP & FINALIZATION
# =============================================================================
motd_ssh
customize
cleanup_lxc
