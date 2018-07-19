#
# Cookbook:: Cloudera_Automation
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe 'Cloudera_Automation::commons'

include_recipe 'Cloudera_Automation::update_host_file'

# include_recipe 'Cloudera_Automation::ntpd_setup'

include_recipe 'Cloudera_Automation::cloudera_repo_setup'

include_recipe 'Cloudera_Automation::cloudera_install_setup'
