# **Assignment 0**: Environment Setup + Virtual Network Stack (Mininet, Stratum, and ONOS) Usage
## Overview
In this assignment, you will learn how to set up a virtual environment, consisting of a network of hosts and switches, using open-source and production-ready tools (like [Mininet](http://mininet.org/) and [ONOS](https://opennetworking.org/onos/)). This will help give an introduction to the Docker containerization toolchain we will be using in the rest of our assignments, as well as serve as a primer to the Software-Defined-Networking (SDN) space for Assignment 4.

Environment setup
* [Part A](#part-a-install-docker): Docker Installation
* [Part B](#Linux-Kernel-module-extensions): Linux Kernel module extensions **(WSL users)** 

Virtual network
* [Part C](#part-c-virtual-network-setup-and-basic-usage): Setup and Basic Usage


## Learning Outcomes

After completing this programming assignment, students should be able to:

* Utilize Docker to retrieve and run software
* Bootstrap a realistic virtual network, running over real kernel, switch and application code

## Part A: Install Docker

[Docker](https://www.docker.com/) is an open-source platform that lets us develop and deploy applications as a collection of fine-grain, OS-agnostic components called containers. These containers allow independently running components of the application to execute in any environment (e.g., Linux, Windows, or Mac) while sharing a single host kernel's resources. Containers differ from Virtual Machines (VMs), where each VM runs its own kernel while sharing a single hardware server. By using Docker, we are also able to distribute a single set of software, speeding up installation and reducing compatability issues.

> **Linux/WSL Users:** *Docker Engine* is the underlying software layer that manages container runtimes and management. It is available for linux environments, and can be installed here: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/).

> **Mac Users:** *Docker Desktop* is a GUI layer on top of *Docker Engine*, and is the only streamlined way to ship *Docker Engine* on Mac desktops. Once you run Desktop, *Docker Engine* will run under the hood, you are able to utilize the `docker` executable. Visit [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/) to download and install the correct version of *Docker Desktop*. After that, run the post installation steps listed here: [https://docs.docker.com/engine/install/linux-postinstall/](https://docs.docker.com/engine/install/linux-postinstall/).

* **Mac Intel-Chip Users:** On Intel-based Macs, Docker Desktop can run x86_64 Linux containers natively without any special configuration.

* **Mac M1-M3 Apple Silicon Users:** 
On Apple Silicon Macs with M1/M2/M3 chips, Docker Desktop uses translation layers to run x86_64 Linux containers: Rosetta 2 emulates x86_64 instructions from amd/x86_64 Docker linux binaries to be able to run natively on the Arm-based Apple Silicon. **Enable Rosetta 2 emulation in Docker Desktop > Settings > General > Use Rosetta**

The nice thing about Docker is that you won't have to spend time installing the various tools and codebases we will use during the programming assignments. Installing these can, at times, become really tedious and time-consuming. Docker offloads all of that grunt work and lets you start using these tools from the get-go (as you will see in a bit)!

## Part B: Linux Kernel module extensions
> **MacOS users**: skip this section.

In order for Mininet to emulate real kernel-level traffic control across its links and virtual switch processes, we need to enable modules that WSL does not expose out of the box.
* `netem`: (also include man page or reference link) network emulation...
* `htb`: (also include man page or reference link) heirarchical token bucket...

Unfortunately, this means recompiling a new Linux kernel. Fortunately, this is not too bad, as we'll simply be compiling a copy of our linux kernel (or similar) with our new modules installed, for loading. Moreover, this is safe, and should not disrupt - we'll simply be compiling a similar copy of the linux kernel with our new modules installed

We've provided scripts to make the process easier. Please feel free to inspect them.
No breaking changes!
### Step 1.

### Step 2.
### Step 3.


## Part C: Virtual Network Setup and Basic Usage
blahblah blah this is MININET and ONOS

### Directory Tree
Scripts blah blah 
Makefile blah

### Basic Usage:
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

### File System Management:
TODO: explain how our docker scripts will mount the current working directory, and how this is a useful tool to be able to copy over source code. Explain what software dependencies the docker container exposes (stratum.py, etc) in order for our topology we give to execute

### Testing on Mininet
TODO: explain how there are two methods, one using mininet CLI to execute compiled objects, the second being xterm. This will be useful for testing our assignment 1 code