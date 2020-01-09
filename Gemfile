source 'https://rubygems.org'

# Specify your gem's dependencies in kubeadm-join-helper.gemspec
gemspec

gem 'execute', '~> 0.1.1', git: 'https://github.com/lscheidler/ruby-execute', branch: 'master'
gem 'overlay_config', '~> 0.1.3', git: 'https://github.com/lscheidler/ruby-overlay_config', branch: 'master'
gem 'plugin_manager', '~> 0.2.0', git: 'https://github.com/lscheidler/ruby-plugin_manager', branch: 'master'

if RUBY_PLATFORM == 'x86_64-linux-gnu' and RUBY_VERSION == '2.3.3'
  # debian stretch packaged gem
  gem 'gpgme', '2.0.12'
elsif RUBY_PLATFORM == 'x86_64-linux-gnu' and RUBY_VERSION == '2.5.5'
  # debian buster packaged gem
  gem 'gpgme', '2.0.18'
else
  gem 'gpgme', '~>2.0.12'
end
