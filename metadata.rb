name 'Cloudera_Automation'
maintainer 'Jitender Singh Gahlot'
maintainer_email 'mail2gahlot@gmail.com'
license 'All Rights Reserved'
description 'Installs/Configures Cloudera Cluster'
long_description 'Installs/Configures Cloudera Cluster'
version '0.1.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/Cloudera_Automation/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/Cloudera_Automation'

depends 'selinux', '~> 2.1.1'
depends 'ntpd', '~> 0.2.1'
depends 'hostsfile', '~> 3.0.1'
