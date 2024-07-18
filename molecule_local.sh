#!/bin/bash

#-------------------------------------------------------------------------------------#
# Run molecule test locally                                                           #
#-------------------------------------------------------------------------------------#
#
# Inputs:  $1 the action the script should execute <init|run>
# Inputs:  $2 the action the script should execute <prepare|create|converge|destroy|test>
# Outputs: log messages
# Results: exit code 1 or 0
#

# constants
EVITA_MOLECULE_TEST_DIR="tests/molecule"
EVITA_MOLECULE_TEST_PATH="../$EVITA_MOLECULE_TEST_DIR"

#--------------------------------------------------------------------------------------------------------#
# create_env_file () - create file to store required environment variables for local test
#
# Inputs:  None
# Outputs: None
#
create_env_file() {
  echo "Create file .env.yml and add required environment variables into for local test"
  cat > "${EVITA_MOLECULE_TEST_PATH}/config/local/.env.yml" <<'EOF'
########################################################################################################
# Attention: this file contains required environment variables, which will be only used for local test #
# Therefore donot commit and push this file                                                            #
########################################################################################################
# set individual proxmox username (i.e. techuser-evita@pve) and token for local test
PROXMOX_USER: "<bku2>@realm"
PROXMOX_USER_TOKEN_ID: "molecule_local"
PROXMOX_USER_TOKEN_SECRET: "<token_secret>"
PROXMOX_HOST: "10.64.248.5"

# set ansible host of molecule test instance
ANSIBLE_LIMIT: "<evita_molecule_test_instance>"
# set path to rufus vault master key
ANSIBLE_VAULT_PASSWORD_FILE: "../../../tests/molecule/config/local/rufus_vault_master"

# set path to custom molecule's config folder
EVITA_MOLECULE_CONFIG_PATH: "../../../tests/molecule/config"

# set path to molecule's inventory folder
EVITA_MOLECULE_INVENTORY_PATH: "../../../inventory/infrastructure"
EOF
}

#------------------------------------------------------------------------------#
# init () - create required files and folders for molecule test
#
# Inputs:  None
# Outputs: None
#
molecule_local_init () {
  if [[ ! -d "$EVITA_MOLECULE_TEST_PATH" ]]; then
    echo "Create test folder $EVITA_MOLECULE_TEST_DIR"
    mkdir -p "$EVITA_MOLECULE_TEST_PATH"/{config/local,verification}

    echo "Create playbook $EVITA_MOLECULE_TEST_DIR/config/converge.yml"
    touch "$EVITA_MOLECULE_TEST_PATH/config/converge.yml"

    echo "Create playbook ${EVITA_MOLECULE_TEST_DIR}/config/converge.yml"
    touch "$EVITA_MOLECULE_TEST_PATH/config/verify.yml"

    echo "Create file ${EVITA_MOLECULE_TEST_PATH}/config/local/.env.yml"
    create_env_file

    echo "Create file ${EVITA_MOLECULE_TEST_PATH}/config/local/rufus_vault_master"
    touch "$EVITA_MOLECULE_TEST_PATH/config/local/rufus_vault_master"

    echo "Add directory $EVITA_MOLECULE_TEST_DIR/config/local to .gitignore"
    echo "$EVITA_MOLECULE_TEST_DIR/config/local/" >> ../.gitignore

    echo "SUCCESS: molecule's initialization completed!"
  else
    echo "Directory $EVITA_MOLECULE_TEST_PATH already exists."
    exit 1
  fi
}

#------------------------------------------------------------------------------#
# molecule_local_run () - run molecule
#
# Inputs:  $1 <prepare|create|converge|verify|destroy|test>
# Outputs: None
#
molecule_local_run () {
  if [[ ! -f "$EVITA_MOLECULE_TEST_PATH/config/local/.env.yml"  ]]; then
    echo "ENV_ERROR: Missing file .env.yml. Please create the file in $EVITA_MOLECULE_TEST_PATH/config/local/.env.yml."
    exit 1
  else
    if [[ "$1" = @(prepare|create|converge|verify|destroy|test) ]]; then
      molecule -e "$EVITA_MOLECULE_TEST_PATH/config/local/.env.yml" "$1"
    else
      echo "ERROR: Invalid action passed - please call ./molecule_local.sh run <prepare|create|converge|verify|destroy|test>" >&2
      exit 1
    fi
  fi
}

case $1 in
  "init")
    molecule_local_init
    ;;
  "run")
      molecule_local_run "$2"
    ;;
  *)
    echo  "ERROR: Invalid action passed - please call ./molecule_local.sh <init|run>" >&2
    exit 1
    ;;
esac
