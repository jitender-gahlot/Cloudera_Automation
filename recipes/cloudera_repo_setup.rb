#
# Cookbook Name:: cm_setup
# Recipe:: cloudera_repo_setup
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
# include_recipe 'hostname::default'

#
# Creating Repo for Cloudera Manager
#

# Setting up repos
# => https://supermarket.chef.io/cookbooks/yum
# => https://github.com/chef-cookbooks/yum/
#

# # add the EPEL repo
# yum_repository 'epel' do
#   description node['yum_repository']['epel']['description']
#   mirrorlist node['yum_repository']['epel']['mirrorlist']
#   gpgkey node['yum_repository']['epel']['gpgkey']
#   action :create
# end

yum_repository 'epel' do
  description 'epel Stable repo'
  baseurl 'http://download.fedoraproject.org/pub/epel/7/$basearch'
  gpgkey 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'
  action :create
end

#
# Installing pip and cm-api for cloudera.
#

yum_package 'python-pip' do
  action :install
end

execute 'pip install --upgrade pip' do
  command 'pip install --upgrade pip'
end

execute 'pip install "cm_api<20"' do
  command 'pip install "cm_api<20"'
end

# [cloudera-manager]
# # Packages for Cloudera Manager, Version 5, on RedHat or CentOS 6 x86_64
# name=Cloudera Manager
# baseurl=https://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/
# gpgkey =https://archive.cloudera.com/cm5/redhat/6/x86_64/cm/RPM-GPG-KEY-cloudera
# gpgcheck = 1

yum_repository 'cloudera-manager' do
  description 'Cloudera Manager'
  baseurl 'https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5/'
  gpgkey 'https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/RPM-GPG-KEY-cloudera'
  action :create
end
