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
            @pm['Kubeadm::Join::Helper::Plugins::Join'].new @config
          when :update
            @pm['Kubeadm::Join::Helper::Plugins::Update'].new @config
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
            opts.on('--additional-config STRING', 'set additional config, which is going to be merged with join config') do |file|
              @config.additional_config = file
            end

            opts.on('--bucket-name STRING', 'set bucket name to use for upload') do |bucket_name|
              @config.bucket_name = bucket_name
            end

            opts.on('--bucket-region STRING', 'set bucket region', "default: #{@config.bucket_region}") do |bucket_region|
              @config.bucket_region = bucket_region
            end

            opts.on('--bucket-prefix STRING', 'set bucket prefix', "default: #{@config.bucket_prefix}") do |bucket_prefix|
              @config.bucket_prefix = bucket_prefix
            end

            opts.on('--cluster NAME', 'set cluster name') do |cluster|
              @config.cluster = cluster
            end

            opts.on('--dryrun', 'dry run') do
              @config.dryrun = true
            end

            opts.on('-j', '--join', 'get token from s3 and run kubeadm join') do
              @action = :join
            end

            opts.on('-n', '--node-name STRING', 'set node name') do |name|
              @config.node_name = name
            end

            opts.on('-r', '--retries INTEGER', '[join] number of retries to get token') do |retries|
              @config.retries = retries.to_i
            end

            opts.on('-u', '--update', 'create new token and upload to s3') do
              @action = :update
            end

            opts.on('--use-instance-id', 'use instance id from aws meta data service as node name') do
              @config.use_instance_id = true
            end

            opts.on('-w', '--wait SECONDS', '[join] wait for SECOND before next try') do |wait|
              @config.wait = wait.to_i
            end
          end
          @options.parse!
        end
      end
    end
  end
end
