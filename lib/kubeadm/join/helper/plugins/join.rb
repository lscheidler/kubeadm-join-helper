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

require 'fileutils'
require 'gpgme'
require 'gpgme/version'
require 'json'
require 'net/http'
require 'ostruct'
require 'stringio'
require 'tempfile'
require 'yaml'

require 'plugin'
require 'aws_imds'

require_relative 'common'

module Kubeadm
  module Join
    module Helper
      module Plugins
        class Join < Common
          # @!macro [attach] plugin_argument
          #   @!attribute $1
          #     $2
          plugin_argument :node_name, description: 'node name', optional: true
          plugin_argument :use_instance_id, description: 'use instance id from aws meta data service as node name', optional: true, default: false
          plugin_argument :additional_config, description: 'additional config, which is going to be merged with join config', optional: true
          plugin_argument :retries, description: 'amount of retries to check, if token exists', optional: true, default: 10
          plugin_argument :wait, description: 'wait time in seconds, before retrying', optional: true, default: 10

          # @raise Aws::S3::Errors::NoSuchKey
          # @raise GPGME::Error::DecryptFailed
          def after_initialize
            super
    
            if not File.exist? '/etc/kubernetes/kubelet.conf'
              get_token
              decrypt_token
              run_join
            end
          end
    
          # get token from s3
          def get_token
            key = File.join( @bucket_prefix, @cluster + ".json" )
            object = @bucket.object(key)
            @retries.times do |x|
              break if object.exists?

              puts "No token found at #{key}. Retry in 10 seconds. (#{x+1}/#{@retries})"
              sleep @wait
            end
            @token_data = JSON::parse(object.get.body.read)
          end
    
          # decrypt token with ruby gpgme version > 1.0.8
          def decrypt_token
            crypto = GPGME::Crypto.new pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK, password: @gpg_passphrases[@token_data["id"]]
    
            @data = JSON::parse(crypto.decrypt(@token_data["data"]).read)
          end

          def run_join
            cmd = case @data['type']
                  when 'config'
                    config = {
                               'apiVersion' => 'kubeadm.k8s.io/v1beta2',
                               'kind' => 'JoinConfiguration',
                               'discovery' => {
                                 'bootstrapToken' => {
                                   'token' => @data['token'],
                                   'apiServerEndpoint' => @data['apiServerEndpoint'],
                                   'caCertHashes' => @data['caCertHashes']
                                 }
                               }
                             }

                    if @additional_config
                      additional_config = YAML::load_file(@additional_config)
                      config.merge!(additional_config)
                    end

                    tempfile = Tempfile.new ['kubeadm', '.yml']
                    tempfile.print(YAML.dump(config))
                    tempfile.close

                    cmd = ['kubeadm', 'join', '--config', tempfile.path]
                    if @node_name or (@use_instance_id and (@node_name=AwsImds.meta_data.instance_id))
                      cmd += ['--node-name', @node_name]
                    end
                    cmd
                  else
                    cmd = @data['joinCommand'].split(' ')
                    if @node_name or (@use_instance_id and (@node_name=AwsImds.meta_data.instance_id))
                      cmd += ['--node-name', @node_name]
                    end
                    cmd
                  end

            Execute::execute cmd, dryrun: @dryrun, print_cmd: true, print_lines: true
          end
        end
      end
    end
  end
end
