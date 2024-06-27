####################################################################
############### Set up Mininet and Controller ######################
####################################################################

NETCFG = ./cfg/netcfg_a1.json
SCRIPTS = ../scripts
PID_FILE = ./pids

.PHONY: mininet controller activate-fwd netcfg install cli all clean

# Check for root privileges
define check_root
	@if [ "`id -u`" -ne 0 ]; then \
		echo "This target must be run as root. Please use sudo."; \
		exit 1; \
	fi
endef

all:
	$(check_root)
	@$(MAKE) inner-all

inner-all: $(PID_FILE) mininet controller install

mininet:
	@xterm -fn fixed -e "/bin/bash -c '\
		$(SCRIPTS)/run_a1.sh; \
		' \
	" & echo $$! >> .pids

controller:
	@xterm -fn fixed -e "/bin/bash -c '\
		ONOS_APPS=gui,proxyarp,drivers.bmv2,lldpprovider,hostprovider \
		$(SCRIPTS)/onos.sh; \
		' \
	" & echo $$! > .pids

# TODO: failure handling and exit signal traps
install: controller
	@echo "Waiting for controller to be up..."
	@while ! nc -z localhost 8181; do \
		printf "."; \
		sleep 2; \
	done
	@echo "Controller up."

	# TODO: can poll specific services instead of cluster
	@echo "Waiting for ONOS services to be ready..."
	@while ! curl --user onos:rocks -s http://localhost:8181/onos/v1/cluster | grep -q '"status":"READY"'; do \
		printf "."; \
		sleep 2; \
	done
	@echo ONOS services ready.


	# Start ONOS CLI as a separate build item
	$(MAKE) cli

	# Install netcfg
	@echo "Installing ONOS network configuration..."
	$(SCRIPTS)/onos-netcfg $(NETCFG)
	

	@echo "Distributing basic forwarding application to switches..."
	@HTTP_CODE=$$(curl --user onos:rocks -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8181/onos/v1/applications/org.onosproject.fwd/active 2>/dev/null); \
	if [ $$HTTP_CODE -eq 200 ]; then \
		echo "Success: Basic forwarding application distributed."; \
	else \
		echo "Failure: Could not distribute basic forwarding application. HTTP status code: $$HTTP_CODE"; \
	fi

activate-fwd:
	curl --user onos:rocks -X POST http://localhost:8181/onos/v1/applications/org.onosproject.fwd/active

netcfg:
	$(SCRIPTS)/onos-netcfg $(NETCFG)

cli:
	@xterm -fn fixed -e "/bin/bash -c '\
		$(SCRIPTS)/onos-cli; \
		' \
	" & echo $$! >> .pids


$(PID_FILE):
	@touch $(PID_FILE)

clean:
	$(check_root)
	@if [ -f .pids ]; then \
		while read -r pid; do \
			kill $$pid || true; \
		done < .pids; \
		rm -f .pids; \
		echo "Cleanup complete."; \
	else \
		echo ".pids file not found, nothing to clean."; \
	fi
