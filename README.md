# a1-docker
Basic Usage:
1. `sudo make all`
    * `mn-stratum` container environment
    * ONOS controller + admin CLI
    * installs network configuration and applications onto ONOS
2. inspect ONOS installation state # TODO: add samples
    * `onos> netcfg`
    * `onos> devices -s`
    * `onos> apps -s | grep fwd`
3. boot mininet in `mn-stratum` container
    ```
    root> python ~/topology_ctl.py
    ```
    * if upon ungraceful shutdown, mininet artifacts will be left behind. use `mn -c` to clean them up
    * inspect `onos> devices -s` to see when all of our `stratum-bmv2` switches are registered and installed correctly by ONOS. this may take upwards of a few minutes worst case, due to slowness in discovery mechanisms. 
4. test network connectivity before and after ALL `mn-stratum` switches have been configured.
    * `mininet> dump` and `mininet> net` to inspect the network
    * `mininet> pingall` and `mininet> pingpair hX hY` to determine reachability

5. `sudo make clean`

Inspect running containers at any time using `sudo docker ps`