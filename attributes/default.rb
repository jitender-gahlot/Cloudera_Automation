 # This is a Chef attributes file. It can be used to specify default and override
 # attributes to be applied to nodes that run this cookbook.


default['host_file_data'] = { 'localhost' => '127.0.0.1' }

default['python_script']['path'] = '/root/deploy_new_cluster.py'
