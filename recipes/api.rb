#
# Cookbook Name:: revily
# Recipe:: api
#
# Copyright 2013, Applied Awesome LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "git"
include_recipe "application"
include_recipe "runit"

include_recipe "revily::ruby"

revily_app "revily-api" do
  path node['revily']['revily-api']['dir']
  owner node['revily']['user']['username']
  group node['revily']['user']['username']
  repository node['revily']['revily-api']['repository']
  revision node['revily']['revily-api']['revision']
  environment "LC_ALL" => "en_US.UTF-8"
  bundler_command "#{node['rbenv']['root_path']}/shims/bundle"
end

template "/etc/nginx/sites-available/revily-api" do
  source "revily-nginx-conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :reload, "service[nginx]"
  variables({
    :name => "revily-api"
  })
end

nginx_site "revily-api"
