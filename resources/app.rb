#
# Cookbook Name:: revily
# Resource:: app
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

actions :create, :remove
default_action :create

attribute :name, :kind_of => String, :name_attribute => true
attribute :owner, :kind_of => String
attribute :group, :kind_of => String
attribute :deploy_key, :kind_of => [String, NilClass], :default => nil
attribute :path, :kind_of => String
attribute :repository, :kind_of => String
attribute :revision, :kind_of => String
attribute :packages, :kind_of => [Array, Hash], :default => []
attribute :bundler, :kind_of => [TrueClass, FalseClass], :default => true
attribute :bundler_command, :kind_of => String, :default => "bundle"
attribute :environment, :kind_of => Hash, :default => {}

def deploy_path
  "#{path}/gitdeploy"
end

def current_path
  "#{path}/current"
end

def shared_path
  "#{path}/shared"
end
