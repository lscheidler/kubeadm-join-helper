# Copyright 2020 Lars Eric Scheidler
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

require "kubeadm/join/helper/version"

require 'optparse'

require 'overlay_config'
require 'plugin_manager'

require_relative 'helper/plugins'

module Kubeadm
  module Join
    module Helper
      # command line interface
      class CLI
        def initialize
          set_defaults
          parse_arguments

          @pm = PluginManager.instance
          case @action
          when :join
            join = @pm['Kubeadm::Join::Helper::Plugins::Join'].new @config
          when :update
            update = @pm['Kubeadm::Join::Helper::Plugins::Update'].new @config
          end
        end

        def set_defaults
          @script_name = File.basename($0)
          @config = OverlayConfig::Config.new config_scope: 'kubeadm-join-helper', defaults: {
            bucket_region: 'eu-central-1',
            bucket_prefix: 'kubeadm-join/',
          }
        end

        def parse_arguments
          @options = OptionParser.new do |opts|
            opts.on('--cluster NAME', 'set cluster name') do |cluster|
              @config.cluster = cluster
            end

            opts.on('--bucket-name NAME', 'set bucket name to use for upload') do |bucket_name|
              @config.bucket_name = bucket_name
            end

            opts.on('--bucket-region NAME', 'set bucket region', "default: #{@config.bucket_region}") do |bucket_region|
              @config.bucket_region = bucket_region
            end

            opts.on('--bucket-prefix PREFIX', 'set bucket prefix', "default: #{@config.bucket_prefix}") do |bucket_prefix|
              @config.bucket_prefix = bucket_prefix
            end

            opts.on('-j', '--join', 'get token from s3 and run kubeadm join') do
              @action = :join
            end

            opts.on('-u', '--update', 'create new token and upload to s3') do
              @action = :update
            end
          end
          @options.parse!
        end
      end
    end
  end
end
