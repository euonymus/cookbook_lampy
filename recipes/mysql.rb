# -*- coding: utf-8 -*-
# MySQL auto restart setting
execute "set auto restart" do
  command "sudo sysv-rc-conf mysql-" + node[:lampy][:app_name] + " on"
end

# Create mysql service
mysql_service node[:lampy][:app_name] do
  port '3306'
  version '5.7'
  charset 'utf8mb4'
  initial_root_password node[:lampy][:db_password_root]
  action [:create, :start]
end
# build mysite.cnf for mysql config
mysql_config node[:lampy][:app_name] do
  instance node[:lampy][:app_name]
  source 'mysite.cnf.erb'
  notifies :restart, 'mysql_service[' + node[:lampy][:app_name] + ']'
  action :create
end

# restart mysql. I thought above "mysql_config" notifies setting restart mysql, but seems not. somehow this below needed.
execute "restart_mysql" do
  command "sudo service mysql-" + node[:lampy][:app_name] + " restart"
end


# Since database cookbook(4.0.7) requires manual install for mysql2_chef_gem
mysql2_chef_gem 'default' do
  # client_version '5.7'
  action :install
end

# This is used repeatedly, so we'll store it in a variable
mysql_connection_info = {
  host:     'localhost',
  username: 'root',
  password: node[:lampy][:db_password_root],
  socket:   '/var/run/mysql-' + node[:lampy][:app_name] + '/mysqld.sock'
}

# Ensure a database exists with the name of our app
mysql_database node[:lampy][:db_name] do
  connection mysql_connection_info
  action     :create
end
mysql_database node[:lampy][:testdb_name] do
  connection mysql_connection_info
  action     :create
end

# Ensure a database user exists with the name of our app
mysql_database_user node[:lampy][:db_user] do
  connection mysql_connection_info
  password   node[:lampy][:db_password]
  action     :create
end
mysql_database_user node[:lampy][:testdb_user] do
  connection mysql_connection_info
  password   node[:lampy][:db_password]
  action     :create
end

# Let this database user access this database
mysql_database_user node[:lampy][:db_user] do
  mysql_connection_info
  password      node[:lampy][:db_password]
  database_name node[:lampy][:db_name]
  host          'localhost'
  action        :grant
end
mysql_database_user node[:lampy][:testdb_user] do
  mysql_connection_info
  password      node[:lampy][:db_password]
  database_name node[:lampy][:testdb_name]
  host          'localhost'
  action        :grant
end

# MySQL timezone 設定
execute "set timezone info into mysql database" do
  command "mysql_tzinfo_to_sql /usr/share/zoneinfo/ | mysql -S /var/run/mysql-" + node[:lampy][:app_name] + "/mysqld.sock -p" + node[:lampy][:db_password_root] + " mysql"
end
