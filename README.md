flows
=====

Flows is a simple wrapper for the nfdump command. It makes it easier to search in the netflow data collected by the nfcapd process. Easily specify the probes and the time window to do a search. Filter results directly on the comand line or use pre-defined filter files, e.g. country filters. This wrapper also enables parallel processing of nfdump queries using GNU Parallel.

Configuration
-------------

The small configuration is located at the beginning of the flows script. Here are the main configuration variables:

`ROOT_FLOW_DIR` is the path to the top directory where nfcapd stores the collected flows. Note that the script assumes a sub directory layout as Y/M/D (as specified by -S 1 argument to nfcapd).

`CMD_LOG_FILE` is the path where the script logs the usage, i.e. the set of arguments used by the users.

`USING_NFSEN` is manually set to either true or false whether you have nfsen installed or not. 

`ALERT_META_PATH` is the path to the profiles-stat directory of nfsen. Only in use if `USING_NFSEN` is set to true.

`CACHE_DIR` specifies the path to where query results are being temporarily saved.

`CACHE_TIME` specifies the number of days the results should be available in the cache.

`TMP_DIR` is the path where the script saves temporary data during execution. The data will be removed after a normal execution.

`OUTPUT` specifies the output format from nfdump. See nfdump documentation for more information.

`FILTERDIR` contains the path to a directory where you have nfdump filter files located. Along with the flows script, I've included a set of country filters.

`LOCALCORES` tries to automatically identify the number of cores available on the local host.

`CLUSTER` specifies a comma separated list of nodes in the processing cluster. The format is <num cores>/user@host. Colon : is used to specify the localhost. Note that /proc/cpuinfo should provide information on the number of CPU cores. Example: `CLUSTER="4/:,8/flows@node01.local,4/flows@node02.local"`

`PRIVKEY` is the path to the private key used by the script for authenticating the login on the nodes in the cluster. Note that you have to manually set up the cluster with ssh accounts and authorized keys.

Installation
------------

When you have updated the script with your configuration, simply execute the `install.sh` script. This script will initialize various log files, directories and some other files. In addition, it will generate a set of asymetrical keys used for ssh authentication between the nodes in the cluster.

If you don't wish to use parallel execution when running this script, simply use the argument `-j` to disable the functionality. You can also run it in parallel only on your local machine, if you don't want to set up a cluster. In that case, add the argument `-J` when running the script. Parallelization may increase the nfdump query processing quite significantly, so I would recommend using it.

When setting up a processing cluster, I recommend adding a dedicated flows user to the system. Upload the public key generated by the installation script to each node in the cluster to the home directory of the flows user. Add the key to the `authorized_keys` file in the .ssh directory: `cat id_flows.pub >> ~./ssh/authorized_keys`. Each node must also have nfdump installed, and a read-only access to the shared datastore where nfcapd stores its collected netflow. And of course GNU Parallel must be installed (get the source from www.gnu.org/software/parallel/).

On the main server, you should update the ssh config in the `PRIVKEY` directory, with all the nodes in the cluster. The flows script will automatically configure the users .ssh directory if the config file and the private keys are accessible.

DEPENDENCIES: This script assumes a specific sub-directory layout for the nfcapd data storage (layout S1 as defined in the nfcapd documentation). The structure should be `<probe>/<year>/<month>/<day>/<datafiles>`. Another depenency is the usage of 5 minutes intervals between data file rotation.


