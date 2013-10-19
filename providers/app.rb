#
# Cookbook Name:: revily
# Provider:: app
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

action :create do
  new_resource.packages.each do |pkg, ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end

  directory new_resource.path do
    owner new_resource.owner
    group new_resource.group
    mode '0755'
    recursive true
  end

  directory new_resource.shared_path do
    owner new_resource.owner
    group new_resource.group
    mode '0755'
    recursive true
  end

  %w{ pids sockets system log }.each do |dir|
    directory "#{new_resource.shared_path}/#{dir}"
  end

  if new_resource.deploy_key
    file "#{new_resource.path}/id_deploy" do
      content new_resource.deploy_key
      owner new_resource.owner
      group new_resource.group
      mode '0600'
    end

    template "#{new_resource.path}/deploy-ssh-wrapper" do
      source "deploy-ssh-wrapper.erb"
      cookbook "application"
      owner new_resource.owner
      group new_resource.group
      mode "0755"
      variables :id => new_resource.name, :deploy_to => new_resource.path
    end
  end

  git new_resource.name do
    action :checkout # We're using capistrano to deploy
    revision new_resource.revision
    repository new_resource.repository
    user new_resource.owner
    group new_resource.group
    destination new_resource.deploy_path
    ssh_wrapper "#{new_resource.path}/deploy-ssh-wrapper" if new_resource.deploy_key
  end

  link new_resource.current_path do
    to new_resource.deploy_path
    user new_resource.owner
    group new_resource.group
  end

  %w{ log public/system tmp/pids }.each do |dir|
    directory "#{new_resource.deploy_path}/#{dir}" do
      action :delete
      recursive true
      not_if { ::File.symlink?("#{new_resource.deploy_path}/#{dir}") }
    end
  end

  %w{ public tmp tmp/cache tmp/sessions }.each do |dir|
    directory "#{new_resource.deploy_path}/#{dir}" do
      recursive true
      user      new_resource.owner
      group     new_resource.group
    end
  end

  links = {
    "log"           => "log",
    "public/system" => "system",
    "tmp/pids"      => "pids",
    "tmp/sockets"   => "sockets"
  }
  links.each do |deploy_dir, shared_dir|
    link "#{new_resource.deploy_path}/#{deploy_dir}" do
      to    "#{new_resource.shared_path}/#{shared_dir}"
      user  new_resource.owner
      group new_resource.group
    end
  end

  file "#{new_resource.shared_path}/.ruby-version" do
    owner new_resource.owner
    group new_resource.group
    mode "0644"
    content node['revily']['ruby']['version']
  end

  execute "#{new_resource.name} bundle install" do
    cwd new_resource.shared_path
    user new_resource.owner
    not_if "cd #{new_resource.deploy_path} && bundle check"
    only_if { new_resource.bundler }
    environment new_resource.environment
    command <<-SH
#{new_resource.bundler_command} install --gemfile #{new_resource.current_path}/Gemfile \
--deployment \
--quiet \
--without 'development test integration cucumber' \
--path #{new_resource.shared_path}/bundle;
SH
  end

  new_resource.updated_by_last_action(true)
end