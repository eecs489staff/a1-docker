#!/bin/bash

# KERNEL_VERSION="5.15.104" - May exist compatibility issues
KERNEL_VERSION="5.15.15"
KERNEL_DIR="/usr/src/linux-$KERNEL_VERSION"
LOG_FILE="kernel_compile_checkpoint.log"
CONFIG_FILE=".config"

function load_variables() {
    if [[ -e "$LOG_FILE" ]]; then
        . "$LOG_FILE"
    else
        already_run_functions=()
    fi
}

function oneof() {
    local item
    for item in "${@:2}"; do
        if [[ "$1" == "$item" ]]; then
            return 0
        fi
    done
    return 1
}

function checkpoint() {
    if oneof "$1" "${already_run_functions[@]}"; then
        return
    fi
    read -p "Do you want to proceed with $1? [(Y)/n]: " response
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        {
            declare -f
            declare -p $(compgen -v | grep -Ev '^(BASH.*|EUID|FUNCNAME|GROUPS|PPID|SHELLOPTS|UID|SHELL|SHLVL|USER|TERM|RANDOM|PIPESTATUS|LINENO|COLUMN|LC_.*|LANG)$')
        } > "$LOG_FILE"
        if ! "$@"; then
            echo "Checkpoint: $1 failed"
            exit 1
        fi
        already_run_functions+=("$1")
    else
        echo "Skipping $1."
    fi
}

function install_dependencies() {
    # read -p "Install dependencies? [(Y)/n]: " response
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        sudo apt-get update && sudo apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev
    fi
}

function download_kernel() {
    if [ ! -d "$KERNEL_DIR" ]; then
        cd /usr/src
        sudo wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz
        sudo tar -xf linux-$KERNEL_VERSION.tar.xz
    else
        echo "Kernel directory $KERNEL_DIR already exists. Skipping download."
    fi
}

function configure_kernel() {
    cd "$KERNEL_DIR"
    # if [ -e "$CONFIG_FILE" ]; then
    #     echo "Kernel configuration file $CONFIG_FILE exists. Modifying existing file."
    # else
    #     echo "Creating kernel configuration file $CONFIG_FILE."
    #     # if ! sudo make oldconfig; then
    #     #     echo "Failed to run 'make oldconfig'. Exiting."
    #     #     exit 1
    #     # fi
    #     if ! sudo make defconfig; then
    #         echo "Failed to run 'make defconfig'. Exiting."
    #         exit 1
    #     fi
    # fi

    # FIXME: 
    # Eventually, need to start with a bare or default config
    # Problem is, some networking configuration isn't set properly with this (e.g. using make defconfig)
    # ...causing WSL to fail to launch upon utilizing this new compiled kernel
    # Using EXISTING user WSL2 config is a TEMPORARY WORKAROUND (presumably, 
    # ...the existing user WSL kernel will have correct config settings that enable WSL networking properly). 
    # Need to find triage the config issue that 
    # ...enables this crucial part of WSL-windows networking s.t. we can work from scratch

    # honestly makes sense b/c a default config will probably not have the necessary modules to enable 
    # ... windows virtualization / serve as a WSL   

    echo "Copying existing WSL2 config as base"
    zcat /proc/config.gz > .config

    # Some config compilations require this
    echo "Set debug info BTF off"
    sed -i 's/CONFIG_DEBUG_INFO_BTF=y/# CONFIG_DEBUG_INFO_BTF is not set/' .config

    echo "Set CONFIG_NET_EMATCH_NETEM, CONFIG_NET_SCH_HTB to module (m) in $CONFIG_FILE."
    sed -i 's/# CONFIG_NET_SCH_HTB is not set/CONFIG_NET_SCH_HTB=m/' .config
    sed -i 's/# CONFIG_NET_EMATCH_NETEM is not set/CONFIG_NET_EMATCH_NETEM=m/' .config
}


function compile_kernel() {
    cd "$KERNEL_DIR"
    sudo make -j$(nproc)
    sudo make modules_install
    sudo make install
}

# FIXME: doesn't check object file location correctly
function check_kernel_modules() { 
    local modules_found=0

    if [ -d "/usr/src/linux-$KERNEL_VERSION" ]; then
        if [ -f "/usr/src/linux-$KERNEL_VERSION/net/sched/sch_netem.ko" ]; then
            echo "Netem module found in /usr/src/linux-$KERNEL_VERSION/net/sched/sch_netem.ko."
            ((modules_found++))
        else
            echo "Netem module not found in /usr/src/linux-$KERNEL_VERSION/net/sched/sch_netem.ko."
        fi

        if [ -f "/usr/src/linux-$KERNEL_VERSION/net/sched/sch_htb.ko" ]; then
            echo "HTB module found in /usr/src/linux-$KERNEL_VERSION/net/sched/sch_htb.ko."
            ((modules_found++))
        else
            echo "HTB module not found in /usr/src/linux-$KERNEL_VERSION/net/sched/sch_htb.ko."
        fi

        if [ "$modules_found" -eq 2 ]; then
            echo "Both Netem and HTB modules are compiled and available in the kernel source directory."
        else
            echo "Not all required modules (Netem and HTB) are compiled and available in the kernel source directory."
        fi
    else
        echo "Kernel source directory /usr/src/linux-$KERNEL_VERSION not found. Modules may not be compiled."
    fi
}

function host_copy_kernel() {
    # Check for 64-bit PowerShell
    if [ -x "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" ]; then
        powershell_path="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    elif [ -x "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" ]; then
        powershell_path="/mnt/c/Windows/SysWOW64/WindowsPowerShell/v1.0/powershell.exe"
    elif [ -x "/mnt/c/Program Files/PowerShell/7/pwsh.exe" ]; then
        powershell_path="/mnt/c/Program Files/PowerShell/7/pwsh.exe"
    elif [ -x "/mnt/c/Program Files/PowerShell/6/pwsh.exe" ]; then
        powershell_path="/mnt/c/Program Files/PowerShell/6/pwsh.exe"
    else
        echo "PowerShell executable not found. Please install PowerShell on your Windows system."
        exit 1
    fi

    # Use the selected PowerShell path
    local windows_user=$(sudo "$powershell_path" -Command '$env:USERNAME' | tr -d '\r')
    local src_file="/usr/src/linux-$KERNEL_VERSION/arch/x86/boot/bzImage"
    local dest_file="/mnt/c/Users/$windows_user/eecs489-linux-$KERNEL_VERSION"
    local wslconfig_path="/mnt/c/Users/$windows_user/.wslconfig"
    local backup_wslconfig_path="/mnt/c/Users/$windows_user/.wslconfigbackup"

    # Copy the kernel source directory to the destination
    if [ -f "$src_file" ]; then
        echo "Copying kernel object to windows filesystem at $dest_file..."
        cp "$src_file" "$dest_file"
        echo "Copied."
    else
        echo "Kernel source directory $src_file does not exist. Cannot copy."
        return 1
    fi

    # Backup and restore .wslconfig
    if [ -f "$wslconfig_path" ]; then
        mv "$wslconfig_path" "$backup_wslconfig_path"
        echo "Existing .wslconfig file backed up to $backup_wslconfig_path."
    else
        echo ".wslconfig file not found. No backup created."
    fi

    # Overwrite the .wslconfig file with the new kernel path
    echo "[wsl2]" > "$wslconfig_path"
    echo "kernel=C:\\\\Users\\\\$windows_user\\\\eecs489-linux-$KERNEL_VERSION" >> "$wslconfig_path"
    echo "New .wslconfig file created with updated kernel path."
    echo "Contents of $wslconfig_path:"
    echo "----------------------------------------"
    cat "$wslconfig_path"
    echo "----------------------------------------"
    
}

function clear_checkpoints() {
    if [[ -e "$LOG_FILE" ]]; then
        rm "$LOG_FILE"
        echo "Checkpoints cleared."
    else
        echo "No checkpoints to clear."
    fi
}

function main() {
    read -p "Do you want to clear all checkpoints and start from scratch? [(Y)/n]: " clear_checkpoints_response
    if [[ "$clear_checkpoints_response" =~ ^[Yy]$ ]] || [[ -z "$clear_checkpoints_response" ]]; then
        clear_checkpoints
    fi

    load_variables

    checkpoint install_dependencies
    checkpoint download_kernel
    checkpoint configure_kernel
    checkpoint compile_kernel

    # check_kernel_modules

    host_copy_kernel

    echo "Compiled and installed successfully: kernel $KERNEL_VERSION with modules: netem, htb."
    echo "Setup complete. Please restart WSL2 to reflect kernel changes."
    echo "* Open PowerShell as Administrator and run:"
    echo "  PS C:\\Users\\youruser> wsl --shutdown"
    echo "* Verify no WSL instances are running:"
    echo "  PS C:\\Users\\youruser> wsl --list --running"
    echo "  (This command should list nothing if no instances are running.)"
    echo "* Start a new WSL instance:"
    echo "  PS C:\\Users\\youruser> wsl"
    echo "In your new WSL instance:"
    echo "* Verify the new kernel version with:"
    echo "  $ uname -r"
    echo "* Load new modules with:"
    echo "  $ sudo modprobe sch_netem"
    echo "  $ sudo modprobe sch_htb"
    echo "* List loaded modules:"
    echo "  $ lsmod"
    echo "  (Ensure sch_netem and sch_htb are listed.)"
    echo "If the modules are loaded, your new kernel setup is ready to use with Mininet!"
    echo "To revert to your old kernel at any time:"
    echo "* Comment out config variable line in .wslconfig, or remove .wslconfig entirely."
    echo "* Modify config variable to point towards old kernel version of your liking."
    echo "* Repeat the steps above to apply the changes."
}

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires superuser privileges. Please run with sudo."
    exit 1
fi

main
