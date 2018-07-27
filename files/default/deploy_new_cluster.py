# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from cm_api.api_client import ApiResource
from cm_api.endpoints.clusters import ApiCluster
from cm_api.endpoints.clusters import create_cluster
from cm_api.endpoints.parcels import ApiParcel
from cm_api.endpoints.parcels import get_parcel
from cm_api.endpoints.cms import ClouderaManager
from cm_api.endpoints.services import ApiService, ApiServiceSetupInfo
from cm_api.endpoints.services import create_service
from cm_api.endpoints.types import ApiCommand, ApiRoleConfigGroupRef
from cm_api.endpoints.role_config_groups import get_role_config_group
from cm_api.endpoints.role_config_groups import ApiRoleConfigGroup
from cm_api.endpoints.roles import ApiRole
from time import sleep

import re

# Configuration
service_types_and_names_all = {
    "ZOOKEEPER": "ZOOKEEPER-1",
    "HDFS": "HDFS-1",
    "MAPREDUCE": "MAPREDUCE-1",
    "HBASE": "HBASE-1",
    "OOZIE": "OOZIE-1",
    "HIVE": "HIVE-1",
    "HUE": "HUE-1",
    "IMPALA": "IMPALA-1",
    "SOLR": "SOLR-1",
    "SQOOP": "SQOOP-1"}

# Configuration
service_types_and_names = {
    "ZOOKEEPER": "ZOOKEEPER-1",
    "HDFS": "HDFS-1",
    "YARN": "YARN"
}

cm_host = "default-centos-7.vagrantup.com"
cm_port = 7180
host_list = ['default-centos-7.vagrantup.com']
cluster_name = "Jitender's Cluster"
cdh_version = "CDH5"  # also valid: "CDH4"
cdh_version_number = "5"  # also valid: 4
hive_metastore_host = "default-centos-7.vagrantup.com"
hive_metastore_name = "<%= node['mysql']['hive']['database_name'] %>"
hive_metastore_password = "<%= node['mysql']['hive']['database_password'] %>"  # enter password here
hive_metastore_database_type = "mysql"
hive_metastore_database_port = "<%= node['mysql']['configuring']['port'] %>"
reports_manager_host = "default-centos-7.vagrantup.com"
reports_manager_name = "<%= node['mysql']['reportman']['database_name'] %>"
reports_manager_username = "<%= node['mysql']['reportman']['database_user'] %>"
reports_manager_password = "<%= node['mysql']['reportman']['database_password'] %>"  # enter password here
reports_manager_database_type = "mysql"
cm_username = "admin"
cm_password = "admin"
cm_service_name = "cloudera-mgmt-node"
host_username = "root"
host_password = "vagrant"
cm_repo_url = None


# cm_repo_url = "deb http://archive.cloudera.com/cm5/ubuntu/lucid/amd64/cm/ lucid-cm5 contrib" # OPTIONAL: only if you want to use a specific repo; this is specific to Debian

def set_up_cluster():
    # get a handle on the instance of CM that we have running
    api = ApiResource(cm_host, cm_port, cm_username, cm_password, version=19)

    # get the CM instance
    cm = ClouderaManager(api)

    print "*************************************"
    print " Starting Auto Deployment of Cluster "
    print "*************************************"

    # {'owner': ROAttr(), 'uuid': ROAttr(), 'expiration': ROAttr(),}
    TRIAL = False
    try:

        trial_active = cm.get_license()
        print trial_active

        if trial_active.owner == "Trial License":
            print "Trial License is already set - will NOT continue now."
            print "Assuming Cluster is already setup"
            TRIAL = True
        else:
            print "Setting up `Trial License`."
            cm.begin_trial()
    except:
        cm.begin_trial()

    if TRIAL:
        exit(0)

    # create the management service
    service_setup = ApiServiceSetupInfo(name=cm_service_name, type="MGMT")

    try:
        if not cm.get_service().name:
            cm.create_mgmt_service(service_setup)
        else:
            print "Service already exist."
    except:
        cm.create_mgmt_service(service_setup)



    # install hosts on this CM instance
    cmd = cm.host_install(host_username, host_list, password=host_password, cm_repo_url=cm_repo_url, unlimited_jce=True)
    print "Installing hosts. This might take a while."
    while cmd.success == None:
        sleep(5)
        cmd = cmd.fetch()
        print cmd

    if cmd.success != True:
        print "cm_host_install failed: " + cmd.resultMessage
        exit(0)


    print "cm_host_install succeeded"

    # first auto-assign roles and auto-configure the CM service
    cm.auto_assign_roles()
    cm.auto_configure()

    # create a cluster on that instance
    cluster = create_cluster(api, cluster_name, cdh_version)

    # add all our hosts to the cluster
    cluster.add_hosts(host_list)

    cluster = api.get_cluster(cluster_name)

    parcels_list = []
    # get and list all available parcels
    print "Available parcels:"
    for p in cluster.get_all_parcels():
        print '\t' + p.product + ' ' + p.version
        if p.version.startswith(cdh_version_number) and p.product == "CDH":
            parcels_list.append(p)

    if len(parcels_list) == 0:
        print "No " + cdh_version + " parcel found!"
        exit(0)

    cdh_parcel = parcels_list[0]
    for p in parcels_list:
        if p.version > cdh_parcel.version:
            cdh_parcel = p

    # download the parcel
    print "Starting parcel download. This might take a while."
    cmd = cdh_parcel.start_download()
    if cmd.success != True:
        print "Parcel download failed!"
        exit(0)

    # make sure the download finishes
    while cdh_parcel.stage != 'DOWNLOADED':
        sleep(5)
        cdh_parcel = get_parcel(api, cdh_parcel.product, cdh_parcel.version, cluster_name)

    print cdh_parcel.product + ' ' + cdh_parcel.version + " downloaded"

    # distribute the parcel
    print "Starting parcel distribution. This might take a while."
    cmd = cdh_parcel.start_distribution()
    if cmd.success != True:
        print "Parcel distribution failed!"
        exit(0)

    # make sure the distribution finishes
    while cdh_parcel.stage != "DISTRIBUTED":
        sleep(5)
        cdh_parcel = get_parcel(api, cdh_parcel.product, cdh_parcel.version, cluster_name)

    print cdh_parcel.product + ' ' + cdh_parcel.version + " distributed"

    # activate the parcel
    cmd = cdh_parcel.activate()
    if cmd.success != True:
        print "Parcel activation failed!"
        exit(0)

    # make sure the activation finishes
    while cdh_parcel.stage != "ACTIVATED":
        cdh_parcel = get_parcel(api, cdh_parcel.product, cdh_parcel.version, cluster_name)

    print cdh_parcel.product + ' ' + cdh_parcel.version + " activated"

    # inspect hosts and print the result
    print "Inspecting hosts. This might take a few minutes."

    cmd = cm.inspect_hosts()
    while cmd.success == None:
        cmd = cmd.fetch()

    if cmd.success != True:
        print "Host inpsection failed!"
        exit(0)

    print "Hosts successfully inspected: \n" + cmd.resultMessage

    # create all the services we want to add; we will only create one instance
    # of each
    for s in service_types_and_names.keys():
        service = cluster.create_service(service_types_and_names[s], s)

    # we will auto-assign roles; you can manually assign roles using the
    # /clusters/{clusterName}/services/{serviceName}/role endpoint or by using
    # ApiService.createRole()
    cluster.auto_assign_roles()
    cluster.auto_configure()

    # # this will set up the Hive and the reports manager databases because we
    # # can't auto-configure those two things
    # hive = cluster.get_service(service_types_and_names["HIVE"])
    # hive_config = {"hive_metastore_database_host": hive_metastore_host, \
    #                "hive_metastore_database_name": hive_metastore_name, \
    #                "hive_metastore_database_password": hive_metastore_password, \
    #                "hive_metastore_database_port": hive_metastore_database_port, \
    #                "hive_metastore_database_type": hive_metastore_database_type}
    # hive.update_config(hive_config)

    # start the management service
    cm_service = cm.get_service()
    cm_service.start().wait()

    # this will set the Reports Manager database password
    # first we find the correct role
    rm_role = None
    for r in cm.get_service().get_all_roles():
        if r.type == "REPORTSMANAGER":
            rm_role = r

    if rm_role == None:
        print "No REPORTSMANAGER role found!"
        exit(0)

    # then we get the corresponding role config group -- even though there is
    # only once instance of each CM management service, we do this just in case
    # it is not placed in the base group
    rm_role_group = rm_role.roleConfigGroupRef
    rm_rcg = get_role_config_group(api, rm_role.type, \
                                   rm_role_group.roleConfigGroupName, None)

    # update the appropriate fields in the config
    rm_rcg_config = {"headlamp_database_host": reports_manager_host, \
                     "headlamp_database_name": reports_manager_name, \
                     "headlamp_database_user": reports_manager_username, \
                     "headlamp_database_password": reports_manager_password, \
                     "headlamp_database_type": reports_manager_database_type}

    rm_rcg.update_config(rm_rcg_config)

    # restart the management service with new configs
    cm_service.restart().wait()

    # execute the first run command
    print "Excuting first run command. This might take a while."
    cmd = cluster.first_run()

    while cmd.success == None:
        cmd = cmd.fetch()

    if cmd.success != True:
        print "The first run command failed: " + cmd.resultMessage()
        exit(0)

    print "First run successfully executed. Your cluster has been set up!"


def main():
    set_up_cluster()


if __name__ == "__main__":
    main()
