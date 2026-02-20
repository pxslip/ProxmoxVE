#!/usr/bin/env bash
# shellcheck source=../misc/build.func
source <(curl -fsSL https://raw.githubusercontent.com/pxslip/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: pxslip
# License: MIT | https://github.com/pxslip/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/qdm12/ddns-updater

# DDNS Updater Update Script

# App Default Values
APP="ddns-updater"
var_tags="${var_tags:-dns;networking}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  # Check if installation exists
  if [[ ! -d /opt/ddns-updater/ddns-updater ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  # check_for_gh_release returns 0 (true) if update available, 1 (false) if not
  if check_for_gh_release "ddns-updater" "qdm12/ddns-updater"; then
    msg_info "Stopping Services"
    systemctl stop ddns-updater
    msg_ok "Stopped Services"

    # Optional: Backup important data before update
    msg_info "Creating Backup"
    mkdir -p /tmp/ddns-updater_backup
    cp -r /opt/ddns-updater/data /tmp/ddns-updater_backup/ 2>/dev/null || true
    msg_ok "Created Backup"

    # CLEAN_INSTALL=1 removes old directory before extracting new version
    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "ddns-updater" "qdm12/ddns-updater" "singlefile" "latest" "/opt/ddns-updater" "ddns-updater_*_linux_amd64"

    # Restore configuration and data
    msg_info "Restoring Data"
    cp -r /tmp/ddns-updater_backup/data/* /opt/ddns-updater/data/ 2>/dev/null || true
    rm -rf /tmp/ddns-updater_backup
    msg_ok "Restored Data"

    # Restart the service
    msg_info "Starting Services"
    systemctl start ddns-updater
    msg_ok "Started Services"

    msg_ok "Updated Successfully"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Update the config file at ${GATEWAY}${BGN}/opt/ddns-updater/config.json${CL}"
