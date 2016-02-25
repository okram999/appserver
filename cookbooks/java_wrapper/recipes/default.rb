#
# Cookbook Name:: java
# Recipe:: default
#
# Copyright (C) 2016 okram999
#
# All rights reserved 
#
include_recipe 'java'

execute "Set the java home directory owner and group permissions" do
	command "chown -R tomcat.tomcat #{node[:java][:java_home]}/"
end
