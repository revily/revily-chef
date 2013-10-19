#
# Cookbook Name:: revily
# Recipe:: postgresql
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

node.set['postgresql']['version'] = node['revily']['postgresql']['version']
node.set['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"

case node['platform_family']
when "debian"
  node.set['postgresql']['enable_pgdg_apt'] = true
  node.set['postgresql']['client']['packages'] = [ "postgresql-client-9.2", "postgresql-server-dev-9.2"]
  node.set['postgresql']['server']['packages'] = [ "postgresql-9.2" ]
  node.set['postgresql']['server']['service_name'] = "postgresql"
  node.set['postgresql']['contrib']['packages'] = [ "postgresql-contrib-9.2" ]
when "rhel"
  node.set['postgresql']['enable_pgdg_yum'] = true
  node.set['postgresql']['client']['packages'] = ["postgresql92", "postgresql92-devel"]
  node.set['postgresql']['server']['packages'] = ["postgresql92-server"]
  node.set['postgresql']['server']['service_name'] = "postgresql-9.2"
  node.set['postgresql']['contrib']['packages'] = ["postgresql92-contrib"]
# else
end
node.set['postgresql']['pg_hba'] = [
  { :type => "host", :db => "all", :user => "all", :addr => "127.0.0.1/32", :method => "trust" },
  { :type => "host", :db => "all", :user => "all", :addr => "::1/128", :method => "trust" }
]
node.set['postgresql']['config']['port'] = node['revily']['postgresql']['port']
node.set['postgresql']['config']['listen_addresses'] = node['revily']['postgresql']['listen']
node.set['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
node.set['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
node.set['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
node.set['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
node.set['postgresql']['config']['max_connections'] = 200
node.set['postgresql']['config']['ssl_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
node.set['postgresql']['config']['ssl_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key'

if (node['memory']['total'].to_i / 4) > ((node['revily']['postgresql']['shmmax'].to_i / 1024) - 2097152)
  # guard against setting shared_buffers > shmmax on hosts with installed RAM > 64GB
  # use 2GB less than shmmax as the default for these large memory machines
  node.set['postgresql']['config']['shared_buffers'] = "14336MB"
else
  node.set['postgresql']['config']['shared_buffers'] = "#{(node['memory']['total'].to_i / 4) / (1024)}MB"
end
node.set['postgresql']['config']['work_mem'] = "8MB"
node.set['postgresql']['config']['effective_cache_size'] = "#{(node['memory']['total'].to_i / 2) / (1024)}MB"
node.set['postgresql']['config']['checkpoint_segments'] = 10
node.set['postgresql']['config']['checkpoint_timeout'] = "5min"
node.set['postgresql']['config']['checkpoint_completion_target'] = 0.9
node.set['postgresql']['config']['checkpoint_warning'] = "30s"

if File.directory?("/etc/sysctl.d") && File.exists?("/etc/init.d/procps")
  # smells like ubuntu...
  service "procps" do
    action :nothing
  end

  template "/etc/sysctl.d/90-postgresql.conf" do
    source "90-postgresql.conf.sysctl.erb"
    owner "root"
    mode  "0644"
    notifies :start, 'service[procps]', :immediately
  end
else
  # hope this works...
  execute "sysctl" do
    command "/sbin/sysctl -p /etc/sysctl.conf"
    action :nothing
  end

  bash "add shm settings" do
    user "root"
    code <<-EOF
      echo 'kernel.shmmax = #{node['revily']['postgresql']['shmmax']}' >> /etc/sysctl.conf
      echo 'kernel.shmall = #{node['revily']['postgresql']['shmall']}' >> /etc/sysctl.conf
    EOF
    notifies :run, 'execute[sysctl]', :immediately
    not_if "egrep '^kernel.shmmax = ' /etc/sysctl.conf"
  end
end

include_recipe "postgresql::client"
include_recipe "postgresql::server"
