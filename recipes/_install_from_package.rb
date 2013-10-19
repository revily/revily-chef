#
# Cookbook Name:: revily
# Recipe:: _install_from_package
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


package_options = ""

case node['platform_family']
when "debian"
  package_options = '--force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew"'

  include_recipe "apt"

  apt_repository "revily" do
    uri "http://repo.revi.ly/apt"
    key "http://repo.revi.ly/apt/pubkey.gpg"
    distribution "revily"
    # components node.sensu.use_unstable_repo ? ["unstable"] : ["main"]
    action :add
  end

  apt_preference "revily" do
    pin "version #{node.revily.version}"
    pin_priority "700"
  end
when "rhel"
  include_recipe "yum"

  yum_repository "revily" do
    description "revily services"
    url "http://repo.revi.ly/yum/el/#{node['platform_version'].to_i}/$basearch/"
    action :add
  end
end

package "revily" do
  version node['revily']['version']
  options package_options
  notifies :create, "ruby_block[revily_service_trigger]", :immediately
end

template "/etc/default/revily" do
  source "revily.default.erb"
end
