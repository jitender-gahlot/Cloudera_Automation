
#
# Cloudera Manager installation and services
#

default['cdh_install']['install_packages'] = [ 'deltarpm', 'oracle-j2sdk1.7', 'cloudera-manager-server-db-2', 'cloudera-manager-agent', 'cloudera-manager-daemons', 'cloudera-manager-server']
default['cdh_install']['cm_services'] = [ 'cloudera-scm-server-db', 'cloudera-scm-server' ]

#
# Repository Configuration
#
# # Setting up repos
# # => https://supermarket.chef.io/cookbooks/yum
# # => https://github.com/chef-cookbooks/yum/
# #
#

# description 'Extra Packages for Enterprise Linux'
# mirrorlist 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
# gpgkey 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'

default['yum_repository']['epel']['description'] = 'Extra Packages for Enterprise Linux'
default['yum_repository']['epel']['mirrorlist'] = 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=$basearch'
default['yum_repository']['epel']['gpgkey'] = 'http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6'

# description 'Packages for Cloudera Manager, Version 5, on RedHat or CentOS 6 x86_64 '
# baseurl 'https://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/'
# gpgkey 'https://archive.cloudera.com/cm5/redhat/6/x86_64/cm/RPM-GPG-KEY-cloudera'

default['yum_repository']['cm']['description'] = 'Packages for Cloudera Manager, Version 5, on RedHat or CentOS 6 x86_64 '
default['yum_repository']['cm']['baseurl'] = 'https://archive.cloudera.com/cm5/redhat/6/x86_64/cm/5/'
default['yum_repository']['cm']['gpgkey'] = 'https://archive.cloudera.com/cm5/redhat/6/x86_64/cm/RPM-GPG-KEY-cloudera'
