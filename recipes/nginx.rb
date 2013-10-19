#
# Cookbook Name:: revily
# Recipe:: nginx
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

node.set['nginx']['default_site_enabled'] = false
node.set['nginx']['install_method'] = 'package'
node.set['nginx']['version'] = '1.4.3'
node.set['nginx']['worker_processes'] = node['cpu']['total'].to_i
node.set['nginx']['worker_connections'] = 10240
node.set['nginx']['sendfile'] = 'on'
node.set['nginx']['tcp_nopush'] = 'on'
node.set['nginx']['tcp_nodelay'] = 'on'
node.set['nginx']['gzip'] = "on"
node.set['nginx']['gzip_http_version'] = "1.0"
node.set['nginx']['gzip_comp_level'] = "2"
node.set['nginx']['gzip_proxied'] = "any"
node.set['nginx']['gzip_types'] = [ "text/plain", "text/css", "application/x-javascript", "text/xml", "application/xml", "application/xml+rss", "text/javascript", "application/json" ]
node.set['nginx']['keepalive_timeout'] = 65
node.set['nginx']['client_max_body_size'] = '250m'
node.set['nginx']['cache_max_size'] = '5000m'


include_recipe "nginx::repo"
include_recipe "nginx"
