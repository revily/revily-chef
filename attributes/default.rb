#
# Cookbook Name:: revily
# Attributes:: default
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

require 'securerandom'

default['revily']['install_type'] = "source"
default['revily']['ruby']['version'] = "2.0.0-p247"
default['revily']['ruby']['bundler_version'] = "1.3.5"

####
# The Revily User that services run as
####
# The username for the revily services user
default['revily']['user']['username'] = "revily"
# The shell for the revily services user
default['revily']['user']['shell'] = "/bin/sh"
# The home directory for the revily services user
default['revily']['user']['home'] = "/opt/revily/embedded"

###
# Load Balancer
###
default['revily']['lb']['enable'] = true
default['revily']['lb']['vip'] = "127.0.0.1"
default['revily']['lb']['api_fqdn'] = node['fqdn']
default['revily']['lb']['web_fqdn'] = node['fqdn']
default['revily']['lb']['debug'] = false
default['revily']['lb']['upstream']['revily-api'] = [ "127.0.0.1" ]
default['revily']['lb']['upstream']['revily-web'] = [ "127.0.0.1" ]

####
# PostgreSQL
####
default['revily']['postgresql']['enable'] = true
default['revily']['postgresql']['version'] = "9.2"
default['revily']['postgresql']['port'] = 5432
default['revily']['postgresql']['listen'] = '127.0.0.1'
default['revily']['postgresql']['shmmax'] = node['kernel']['machine'] =~ /x86_64/ ? 17179869184 : 4294967295
default['revily']['postgresql']['shmall'] = node['kernel']['machine'] =~ /x86_64/ ? 4194304 : 1048575

####
# Redis
####
# servers attributes accepts all values valid to redisio cookbook (https://github.com/brianbianco/redisio)
default['revily']['redis']['enable'] = true
default['revily']['redis']['version'] = "2.6.16"
default['revily']['redis']['listen'] = '127.0.0.1'
default['revily']['redis']['servers'] = {
  'sidekiq'  => { 'port' => 16379 }, # sidekiq jobs
  'cache'    => { 'port' => 16380 }, # rails cache store
  'session'  => { 'port' => 16381 }  # rails session store
}

####
# Revily API
####
default['revily']['revily-api']['enable'] = true
default['revily']['revily-api']['repository'] = "https://github.com/revily/revily"
default['revily']['revily-api']['revision'] = "master"
default['revily']['revily-api']['dir'] = "/var/opt/revily/revily-api"
default['revily']['revily-api']['log_directory'] = "/var/log/revily/revily-api"
default['revily']['revily-api']['environment'] = "production"
default['revily']['revily-api']['environment_variables'] = {
  "SECRET_TOKEN"           => SecureRandom.hex(64),
  "TWILIO_ACCOUNT_SID"     => "AC6d1876a59a704b238042d1d6a61db",
  "TWILIO_APPLICATION_SID" => "APd1876a59a704b238042d1d6a61db",
  "TWILIO_AUTH_TOKEN"      => "c93b7006914f515b0b26ea5168bd875f",
  "TWILIO_NUMBER"          => "+15175551212",
  "MAILER_URL"             => "example.com",
  "MAILER_DELIVERY_METHOD" => "mailgun",
  "DEVISE_MAILER_SENDER"   => "revily@example.com",
  "MAILGUN_API_KEY"        => "key-1x0rtfuhslbfusisx9lucnk7i6r6tt81",
  "MAILGUN_DOMAIN"         => "go.revi.ly",
  "REVILY_REDIS_CACHE_URL" => "redis://localhost:#{node['revily']['redis']['servers']['cache']['port']}/0",
  "NEW_RELIC_LICENSE"      => "da7bcd4e6c9b0fa344104e6643f1494123259beb",
}
default['revily']['revily-api']['listen'] = "127.0.0.1"
default['revily']['revily-api']['vip'] = "127.0.0.1"
default['revily']['revily-api']['port'] = "9001"
default['revily']['revily-api']['backlog'] = 1024
default['revily']['revily-api']['tcp_nodelay'] = true
default['revily']['revily-api']['worker_timeout'] = 3600
default['revily']['revily-api']['umask'] = "0022"
default['revily']['revily-api']['worker_processes'] = 2
default['revily']['revily-api']['session_key'] = "_revily_api_session"
default['revily']['revily-api']['cookie_domain'] = "all"
default['revily']['revily-api']['cookie_secret'] = "ce75a8f9a9dd21c8e4bcc9a68c21939a17bbd8dbd1d8aa8fc68eefbb8d8bbf92ab82a4a62d0124a25b68afea2d0a8dcfaea3dc84686ff906a3e184f032e7b306"

####
# Revily Web UI
####
default['revily']['revily-web']['enable'] = true
default['revily']['revily-web']['repository'] = "https://github.com/revily/revily-web"
default['revily']['revily-api']['revision'] = "master"
default['revily']['revily-web']['dir'] = "/var/opt/revily/revily-web"
default['revily']['revily-web']['log_directory'] = "/var/log/revily/revily-web"
default['revily']['revily-web']['environment'] = 'production'
default['revily']['revily-web']['environment_variables'] = {
  "SECRET_TOKEN"             => SecureRandom.hex(64),
  "REVILY_API_ENDPOINT"      => "https://revily.example.com",
  "REVILY_REDIS_SESSION_URL" => "redis://localhost:#{node['revily']['redis']['servers']['session']['port']}/0",
  "REVILY_API_CLIENT_ID"     => "555f5377f39f1eab4fb5185c88bda3995c90f85142b883478c83edd62e0dba2d",
  "REVILY_API_CLIENT_SECRET" => "f2eced0e39638b0507ace0a390553b0c27756739653bafdbbeeaf17206623124",
}
default['revily']['revily-web']['listen'] = '127.0.0.1'
default['revily']['revily-web']['vip'] = '127.0.0.1'
default['revily']['revily-web']['port'] = "9002"
default['revily']['revily-web']['backlog'] = 1024
default['revily']['revily-web']['tcp_nodelay'] = true
default['revily']['revily-web']['worker_timeout'] = 3600
default['revily']['revily-web']['umask'] = "0022"
default['revily']['revily-web']['worker_processes'] = 2
default['revily']['revily-web']['session_key'] = "_revily_web_session"
default['revily']['revily-web']['cookie_domain'] = "all"
default['revily']['revily-web']['cookie_secret'] = "706fb638d82c90b3f6496900da5215de7f77211e73e0b611e68f3d4c62c351d2fb8db7a82f59e1863d479db0b60d405c8bdde82a4d5ee6bfc2935182fbf5cfa2"
