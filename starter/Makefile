####################################################################
############### Set up Mininet and Controller ######################
####################################################################

NETCFG = ./cfg/netcfg_a1.json
SCRIPTS = ../scripts
PID_FILE = ./pids

.PHONY: mininet controller activate-fwd netcfg install cli install-fwd489 all clean

# Check for root privileges
define check_root
	@if [ "`id -u`" -ne 0 ]; then \
		echo "This target must be run as root. Please use sudo."; \
		exit 1; \
	fi
endef

mininet:
	@if ! lsmod | grep -q sch_netem; then \
	    echo "Loading sch_netem module..."; \
	    sudo modprobe sch_netem; \
	fi
	@if ! lsmod | grep -q sch_htb; then \
	    echo "Loading sch_htb module..."; \
	    sudo modprobe sch_htb; \
	fi
	@echo "Starting Mininet..."
	@$(SCRIPTS)/run_a1.sh
	@echo "Mininet process completed."

controller:
	@echo "Starting ONOS controller..."
	@ONOS_APPS=gui,proxyarp,drivers.bmv2,lldpprovider,hostprovider $(SCRIPTS)/onos.sh
	@echo "ONOS controller process completed."


activate-fwd:
	curl --user onos:rocks -X POST http://localhost:8181/onos/v1/applications/org.onosproject.fwd/active

netcfg:
	$(SCRIPTS)/onos-netcfg.sh $(NETCFG)

# OAR_FILE=onos-app-fwd489-1.9.0-SNAPSHOT.oar
OAR_FILE=fwd489-1.0.0.oar
ONOS_URL=http://localhost:8181/onos/v1
APP_NAME=org.onosproject.fwd489

install-fwd489:
	# Uninstall the existing fwd489 app if it exists
	curl --user onos:rocks -X DELETE ${ONOS_URL}/applications/${APP_NAME}
	# Upload the OAR file
	curl --user onos:rocks -X POST -H "Content-Type: application/octet-stream" --data-binary @${OAR_FILE} ${ONOS_URL}/applications

cli:
	@echo "Starting ONOS CLI (passwd: rocks)..."
	@$(SCRIPTS)/onos-cli.sh

# for tmux users
tmux:
	$(check_root)
	@tmux new-session -d -s a1 -n onos "ONOS_APPS=gui,proxyarp,drivers.bmv2,lldpprovider,hostprovider $(SCRIPTS)/onos.sh; read"
	@tmux new-window -t a1:1 -n mininet "$(SCRIPTS)/run_a1.sh; read"
	@tmux new-window -t a1:2 -n bash

	# @echo "Useful tmux commands:"
	# @echo "  - In-session management:"
	# @echo "      - Ctrl+b, n (next window)"
	# @echo "      - Ctrl+b, p (previous window)"
	# @echo "      - Ctrl+b, <number> (switch to a specific window)"
	# @echo "      - Ctrl+b, c (create window)"
	# @echo "      - Ctrl+b, & (delete window)"
	# @echo "      - Ctrl+b, , (rename window)"
	# @echo "      - Ctrl+b, d (detach session)"
	# @echo "  - Session management:"
	# @echo "      - (sudo) tmux ls"
	# @echo "      - (sudo) tmux attach -t <name>"
	# @echo "      - (sudo) tmux kill-session -t <name>"
	# @echo ""
	@echo "====  tmux session 'a1' started  ===="
	@echo "To attach: \033[1msudo tmux attach -t a1\033[0m"

$(PID_FILE):
	@touch $(PID_FILE)

clean:
	$(check_root)
	# Clean up Docker containers
	@if sudo docker ps -a --filter "name=eecs489-" --format '{{.Names}}' | grep -q "eecs489-"; then \
		sudo docker stop $$(docker ps -a --filter "name=eecs489-" --format '{{.Names}}'); \
		sudo docker rm $$(docker ps -a --filter "name=eecs489-" --format '{{.Names}}'); \
		echo "Docker container cleanup complete."; \
	else \
		echo "No Docker containers found to clean up."; \
	fi

	# Clean up a1 tmux sessions
	@if tmux list-sessions 2>/dev/null | grep -q "a1"; then \
		tmux kill-session -t a1; \
		echo "tmux session cleanup complete."; \
	else \
		echo "No tmux session found to clean up."; \
	fi