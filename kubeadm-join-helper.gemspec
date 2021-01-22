# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kubeadm/join/helper/version'

Gem::Specification.new do |spec|
  spec.name          = "kubeadm-join-helper"
  spec.version       = Kubeadm::Join::Helper::VERSION
  spec.authors       = ["Lars Eric Scheidler"]
  spec.email         = ["lscheidler@liventy.de"]

  spec.summary       = %q{kubeadm join helper}
  spec.description   = %q{saves and retrieves kubeadm join tokens from s3}
  spec.homepage      = "https://github.com/lscheidler/kubeadm-join-helper"
  spec.license       = "Apache-2.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.13"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_runtime_dependency "aws-sdk-s3", "~> 1"
end
