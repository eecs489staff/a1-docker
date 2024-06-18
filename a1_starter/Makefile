############################################################################
##
##     This file is part of Purdue CS 422.
##
##     Purdue CS 422 is free software: you can redistribute it and/or modify
##     it under the terms of the GNU General Public License as published by
##     the Free Software Foundation, either version 3 of the License, or
##     (at your option) any later version.
##
##     Purdue CS 422 is distributed in the hope that it will be useful,
##     but WITHOUT ANY WARRANTY; without even the implied warranty of
##     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##     GNU General Public License for more details.
##
##     You should have received a copy of the GNU General Public License
##     along with Purdue CS 422. If not, see <https://www.gnu.org/licenses/>.
##
#############################################################################

####################################################################
############### Set up Mininet and Controller ######################
####################################################################

SCRIPTS = ../scripts
PID_FILE = .pids

.PHONY: mininet controller activate-fwd netcfg install all clean

all: $(PID_FILE) mininet controller install

mininet:
	@xterm -fn fixed -e "/bin/bash -c '\
		$(SCRIPTS)/run_a1.sh; \
		' \
	" & echo $$! >> .pids

controller:
	@xterm -fn fixed -e "/bin/bash -c '\
		$(SCRIPTS)/onos.sh; \
		' \
	" & echo $$! > .pids

# install: controller netcfg activate-fwd
# FIXME: exit signal traps
install: controller
	@echo "Waiting for controller to be up..."
	@while ! nc -z localhost 8181; do \
		printf "."; \
		sleep 2; \
	done
	@echo "Controller up."

	@echo "Waiting for ONOS services to be ready..."
	@while ! curl --user onos:rocks -s http://localhost:8181/onos/v1/cluster | grep -q '"status":"READY"'; do \
		printf "."; \
		sleep 2; \
	done
	@echo ONOS serviced ready.

	# TODO: discover return code
	@echo "Installing ONOS network configuration..."
	$(SCRIPTS)/onos-netcfg cfg/netcfg.json
	# $(SCRIPTS)/onos-netcfg cfg/netcfg.json & echo $$! >> $(PID_FILE)

	# FIXME: control flow
	@echo "Distributing basic forwarding application to switches..."
	# curl --user onos:rocks -X POST http://localhost:8181/onos/v1/applications/org.onosproject.fwd/active
	@HTTP_CODE=$$(curl --user onos:rocks -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8181/onos/v1/applications/org.onosproject.fwd/active 2>/dev/null); \
	if [ $$HTTP_CODE -eq 200 ]; then \
		echo "Success: Basic forwarding application distributed."; \
	else \
		echo "Failure: Could not distribute basic forwarding application. HTTP status code: $$HTTP_CODE"; \
	fi

activate-fwd:
	curl --user onos:rocks -X POST http://localhost:8181/onos/v1/applications/org.onosproject.fwd/active

netcfg:
	$(SCRIPTS)/onos-netcfg cfg/netcfg.json & echo $$! >> $(PID_FILE)



$(PID_FILE):
	@touch $(PID_FILE)

clean:
	@if [ -f .pids ]; then \
		while read -r pid; do \
			kill $$pid || true; \
		done < .pids; \
		rm -f .pids; \
		echo "Cleanup complete."; \
	else \
		echo ".pids file not found, nothing to clean."; \
	fi