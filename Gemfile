source "https://rubygems.org"

gem "chef", (ENV["CHEF_VERSION"] || ">= 11.0")
gem "foodcritic"
gem "minitest"
gem "tailor"

group :integration do
  gem "berkshelf", "~> 2.0"
  gem "chef-zero"
  gem "kitchen-vagrant"
  gem "test-kitchen", "~> 1.0.0.beta.2"
end
