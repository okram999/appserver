
ark "tomcat-#{node[:tomcat][:version]}" do
  url "http://archive.apache.org/dist/tomcat/tomcat-7/v#{node[:tomcat][:version]}/bin/apache-tomcat-#{node[:tomcat][:version]}.tar.gz"
  path "#{node[:base_dir]}"
  owner 'tomcat'
  group 'tomcat'
  action :put
end

link "#{node[:base_dir]}/tomcat" do
  to "#{node[:base_dir]}/tomcat-#{node[:tomcat][:version]}"
  owner 'tomcat'
  group 'tomcat'
end

directory "#{node[:base_dir]}/tomcat-#{node[:tomcat][:version]}/bin" do
  owner 'tomcat'
  group 'tomcat'
  recursive true
end

directory "#{node[:base_dir]}/tomcat-#{node[:tomcat][:version]}/conf" do
  owner 'tomcat'
  group 'tomcat'
  recursive true
end


template "#{node[:base_dir]}/tomcat-#{node[:tomcat][:version]}/bin/setenv.sh" do
  source 'setenv.sh.erb'
  mode 00755
  variables(
    :java_home => "#{node[:java][:java_home]}",
    :min_mem => node[:tomcat][:minimum_memory],
    :max_mem => node[:tomcat][:maximum_memory],
    :log_location => node[:tomcat][:app_log_dir],
    :jmx_port => node[:tomcat][:jmx][:port],
    :jmx_ssl => node[:tomcat][:jmx][:ssl],
    :jmx_auth => node[:tomcat][:jmx][:authentication]
  )
end

credentials = Chef::EncryptedDataBagItem.load("#{node.chef_environment}", "#{node.chef_environment}")

template "#{node[:base_dir]}/tomcat-#{node[:tomcat][:version]}/conf/tomcat-users.xml" do
  source 'tomcat-users.xml.erb'
  owner 'tomcat'
  group 'tomcat'
  variables(
    :tomcat_username => credentials['tomcat']['username'],
    :tomcat_password => credentials['tomcat']['password'],
    :tomcat_deploy_username => credentials['tomcat_deploy']['username'],
    :tomcat_deploy_password => credentials['tomcat_deploy']['password'],
  )
end



template "/etc/init.d/tomcat" do
  source 'tomcat_init.erb'
  mode 00755
  owner 'root'
  group 'root'
  variables(
    :tomcat_home => "#{node[:base_dir]}/tomcat",
  )
end

template '/opt/mount1/java/jre/lib/management/jmxremote.access' do
  source 'jmxremote.access.erb'
  mode 00600
  owner 'tomcat'
  group 'tomcat'
  variables(
    :jmx_user => credentials['zabbix_user']['username']
  )
  notifies :restart, "service[tomcat]", :delayed
end

template '/opt/mount1/java/jre/lib/management/jmxremote.password' do
  source 'jmxremote.password.erb'
  mode 00600
  owner 'tomcat'
  group 'tomcat'
  variables(
    :jmx_user => credentials['zabbix_user']['username'],
    :jmx_pass => credentials['zabbix_user']['password']
  )
  notifies :restart, "service[tomcat]", :delayed
end

execute 'Ensure tomcat permissions are set properly' do
  command "chown -R tomcat:tomcat #{node[:base_dir]}/tomcat-#{node[:tomcat][:version]}"
end

template "/etc/logrotate.d/tomcat_catalina_out" do
  source "logrotate.erb"
  mode 00600
  variables(:log_file => "#{node['tomcat']['log_dir']}/catalina.out",
            :log_occurance => 'daily',
            :files_to_keep => '10',
            :owner_mode => 'create 644 tomcat tomcat')
end

service "tomcat" do
  action :enable
end

execute "start tomcat" do
  command "service tomcat start"
end
