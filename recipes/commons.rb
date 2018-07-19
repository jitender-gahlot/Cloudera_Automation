#
# Cookbook Name:: cm_setup
# Recipe:: commons
#
# Copyright (c) 2016 Zubair AHMED.
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





# Disable selinux_state
# => https://github.com/skottler/selinux
# => https://supermarket.chef.io/cookbooks/selinux
#
#
# selinux_state 'SELinux Disable' do
#   action :disabled
# end


#
# disabled `iptables`
#

service 'iptables' do
  action [:stop, :disable]
end


#
# Installing python and cm-api
# => https://supermarket.chef.io/cookbooks/poise-python
#


#
# Python Script to deploy cluster.
#

cookbook_file '/root/deploy_new_cluster.py' do
  source 'deploy_new_cluster.py'
  owner 'root'
  group 'root'
  mode '0777'
end

# template node['python_script']['path'] do
#   source 'deploy_new_cluster.py'
#   owner 'root'
#   group 'root'
#   mode '0777'
# end
