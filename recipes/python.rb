python_runtime '3'

python_virtualenv '/var/www/lampapp/.env'

# python_package 'Django' do
#   version '1.8'
# end

pip_requirements '/var/www/lampapp/requirements.txt'


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

# package 'python' do
#   action :install
# end
# package 'python-venv' do
#   action :install
# end
