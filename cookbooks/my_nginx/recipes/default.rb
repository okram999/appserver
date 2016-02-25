#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright (C) 2016 okram999
#
# All rights reserved
#
package 'nginx' do
  version "#{node[:nginx][:version]}"
  not_if "rpm -qa | grep -i nginx-#{node[:nginx][:version]}"
end

template "/etc/nginx/conf.d/default.conf" do
  source "nginx-default.conf.erb"
  mode 00644
  variables(
      :listen_port => node[:nginx][:listen_port],
      :server_name => node[:nginx][:server_name],
      :basic_auth_enabled => node[:nginx][:basic_auth],
      )
  notifies :restart, "service[nginx]", :delayed
end

service "nginx" do
  action [:enable, :start]
end
