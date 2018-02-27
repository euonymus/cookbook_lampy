default[:lampy][:app_name]     = 'lampapp'

default[:lampy][:www_root]     = "/var/www"
default[:lampy][:app_root]     = "#{node[:lampy][:www_root]}/#{node[:lampy][:app_name]}"

default[:lampy][:app_source]  = "/vagrant/src/#{node[:lampy][:app_name]}"

default[:lampy][:shell_base]  = '/usr/local/bin'

# The path to the data_bag_key on the remote server
default[:lampy][:secretpath] = "/vagrant/src/secrets/data_bag_key"

# look for secret in file pointed to with lampy attribute :secretpath
data_bag_secret = Chef::EncryptedDataBagItem.load_secret("#{node[:lampy][:secretpath]}")

# Set domains from data_bag
domain_creds = Chef::EncryptedDataBagItem.load("envs", "domain", data_bag_secret)
if data_bag_secret && domain_envs = domain_creds[node.chef_environment]
  default[:lampy][:domain] = domain_envs['domain']
end

# Set MySQL info from data_bag
mysqlinfo_creds = Chef::EncryptedDataBagItem.load("envs", "mysql", data_bag_secret)
if data_bag_secret && mysql_envs = mysqlinfo_creds[node.chef_environment]
  default[:lampy][:db_name]      = mysql_envs['db_name']
  default[:lampy][:db_user]      = mysql_envs['db_user']
  default[:lampy][:testdb_name]  = mysql_envs['testdb_name']
  default[:lampy][:testdb_user]  = mysql_envs['testdb_user']
end
# Set MySQL passwords from data_bag
mysql_creds = Chef::EncryptedDataBagItem.load("passwords", "mysql", data_bag_secret)
if data_bag_secret && mysql_passwords = mysql_creds[node.chef_environment]
  default[:lampy][:db_password_root] = mysql_passwords['root']
  default[:lampy][:db_password] = mysql_passwords['app']
end

