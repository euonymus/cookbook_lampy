python_runtime '3'

# delete .env directory if it exists
directory "#{node[:lampy][:app_root]}/.env" do
  recursive true
  action :delete
end

python_virtualenv "#{node[:lampy][:app_root]}/.env"

# python_package 'Django' do
#   version '1.8'
# end

# include_recipe 'apache2::mod_wsgi'
case node['platform_family']
when 'debian'
  package 'libapache2-mod-wsgi-py3'
when 'rhel', 'fedora', 'arch', 'amazon'
  package 'mod_wsgi' do
    notifies :run, 'execute[generate-module-list]', :immediately
  end
end

file "#{node['apache']['dir']}/conf.d/wsgi.conf" do
  content '# conf is under mods-available/wsgi.conf - apache2 cookbook\n'
  only_if { ::Dir.exist?("#{node['apache']['dir']}/conf.d") }
end

apache_module 'wsgi'


# settings for vhost with wsgi
directory(node[:lampy][:www_root])
# put apache config
web_app(node[:lampy][:app_name]) do
  server_name(node[:lampy][:domain])
  docroot(node[:lampy][:app_root])
  template('vhost_wsgi.conf.erb')
end
