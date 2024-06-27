# a1-docker
## Dependencies
* Docker runtime
* Unix-based tooling
  * `xterm` - terminal emulation (UI/UX). Depends on `X Server` GUI and user input server. 
    - **WSL2**: X Server out of the box and configured, just use `apt`:
      ```
      sudo apt-get install xterm
      ```
    - **WSL1** - configure X Server on Windows: see [Appendix A](#appendix-a-installing-xterm-on-wsl1-with-x-server-vcxsrv)
    - **MacOS** - requires `X Server`. Install using `xquartz`: see [Appendix B](#appendix-b-macos-xquartz-and-xterm-installation)

## Basic Usage:

1. **Build and Install:**
   - Run `sudo make all`:
     - Sets up `mn-stratum` container environment.
     - Starts ONOS controller and admin CLI.
     - Installs network configuration and applications onto ONOS.

2. **Inspect ONOS State:**
   - Check ONOS installation state:
     - `onos> netcfg`
     - `onos> devices -s`
     - `onos> apps -s | grep fwd`

3. **Start Mininet:**
   - Boot Mininet in `mn-stratum` container:
     ```
     root> python ~/topology_ctl.py
     ```
     - Use `mn -c` to clean up Mininet artifacts if an ungraceful shutdown occurs.
     - Monitor `onos> devices -s` for correct registration and installation of `stratum-bmv2` switches by ONOS. This process may take several minutes due to the discovery mechanism. 
     - **Note**: to ensure correctness, wait for all devices to be registered before testing network connectivity.

4. **Test Network Connectivity:**
   - Check connectivity before and after configuring all `mn-stratum` switches:
     - `mininet> dump` and `mininet> net` to inspect network topology.
     - `mininet> pingall` and `mininet> pingpair hX hY` to verify reachability.

5. **Clean Up:**
   - Run `sudo make clean` to clean up the environment.

**Additional Information:**
- Use `sudo docker ps` to inspect running containers at any time.

## File System Management:
TODO: explain how our docker scripts will mount the current working directory, and how this is a useful tool to be able to copy over source code. Explain what software dependencies the docker container exposes (stratum.py, etc) in order for our topology we give to execute

## Testing on Mininet
TODO: explain how there are two methods, one using mininet CLI to execute compiled objects, the second being xterm. This will be useful for testing our assignment 1 code



## Appendix A: Installing xterm on WSL1 with X Server (VcXsrv)

### Step 1: Install an X Server on Windows

1. **Download and Install VcXsrv**:
   - Go to the [VcXsrv download page](https://sourceforge.net/projects/vcxsrv/).
   - Download the installer and run it to install VcXsrv.
   - During the installation, you can select the default options.

2. **Configure VcXsrv**:
   - After installation, start VcXsrv.
   - Choose the "Multiple windows" option.
   - Ensure "Start no client" is selected.
   - Check "Disable access control" (for testing purposes; you might want to set up more secure access control for production use).
   - Finish the configuration and start the server.

### Step 2: Configure WSL1

1. **Install xterm in WSL1**:
   - Open your WSL1 terminal (e.g., Ubuntu for Windows).
   - Update your package list and install xterm:
     ```bash
     sudo apt update
     sudo apt install xterm
     ```

2. **Set the DISPLAY Environment Variable**:
   - You need to set the `DISPLAY` environment variable to point to your Windows X server.
   - Determine your Windows IP address in your local network by running the following in a Windows Command Prompt:
     ```bash
     ipconfig
     ```
   - Look for the IPv4 address in the output (e.g., `192.168.1.100`).
   - In your WSL1 terminal, set the `DISPLAY` variable:
     ```bash
     export DISPLAY=192.168.1.100:0
     ```
     Replace `192.168.1.100` with your actual IP address.

   - To make this setting persistent, you can add the export line to your `~/.bashrc` file:
     ```bash
     echo "export DISPLAY=192.168.1.100:0" >> ~/.bashrc
     ```

### Step 3: Run xterm

1. **Start xterm**:
   - With the X server running on Windows and the `DISPLAY` variable set in WSL1, you can now start xterm by running:
     ```bash
     xterm &
     ```
   - This should open an xterm window on your Windows desktop.

### Additional Tips

- **Troubleshooting**:
  - Ensure your firewall allows connections to VcXsrv.
  - Make sure VcXsrv is running when you try to launch xterm.
  - If xterm doesn't start, check the `DISPLAY` variable and ensure it points to the correct IP address.

- **Alternative X Servers**:
  - You can also use other X servers like Xming, but the setup process is similar.

## Appendix B: MacOS: XQuartz and xterm installation
1. **Homebrew installation**:
    ```bash
    brew install --cask xquartz
    brew install xterm
    ```
2. **Open XQuartz**:
    ```bash
    open -a XQuartz
    ```
3. **Set DISPLAY Variable and Launch xterm**:
    ```bash
    export DISPLAY=:0
    xterm &
    ```
The xterm window should now appear on your screen, managed by XQuartz.