#
# Cookbook Name:: revily
# Recipe:: default
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

ruby_block "revily_service_trigger" do
  block do
    # Revily service action trigger for LWRP's
  end
  action :nothing
end

case node['revily']['install_type']
when "package"
  include_recipe "revily::_install_from_package"
when "source"
  include_recipe "revily::_install_from_source"
end
