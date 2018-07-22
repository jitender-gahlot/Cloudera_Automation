#
# Cookbook Name:: cm_setup
# Recipe:: cloudera_install_setup
#
# Copyright (c) 2016 Jitender Gahlot.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#
# Setting up cloudera repository
#

include_recipe 'Cloudera_Automation::cloudera_repo_setup'

#
# Installing Packages for Cloudera Manager.
#

node['cdh_install']['install_packages'].each do |pkgs_to_install|
  package pkgs_to_install do
    action :install
  end
end

#
# Configuring cloudera with new mysql database.
# => /usr/share/cmf/schema/scm_prepare_database.sh
# => /etc/cloudera-scm-server/db.properties
#

# include_recipe 'cm_setup::cmdb_config'
#
# Starting `cloudera-manager` service
# => https://docs.chef.io/resource_service.html
#

include_recipe 'Cloudera_Automation::cdh_service'
