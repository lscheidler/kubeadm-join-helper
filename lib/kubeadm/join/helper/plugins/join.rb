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

require 'plugin'
require 'aws_imds'

require_relative 'common'

module Kubeadm
  module Join
    module Helper
      module Plugins
        class Join < Common
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
            10.times do |x|
              break if object.exists?

              puts "No token found at #{key}. Retry in 10 seconds. (#{x+1}/10)"
              sleep 10
            end
            @token_data = JSON::parse(object.get.body.read)
          end
    
          # decrypt token with ruby gpgme version > 1.0.8
          def decrypt_token
            crypto = GPGME::Crypto.new pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK, password: @gpg_passphrases[@token_data["id"]]
    
            @token_cmd = crypto.decrypt(@token_data["data"]).read
          end

          def run_join
            cmd = @token_cmd.split(' ')
            if (nodename=AwsImds.meta_data.instance_id)
              cmd += ['--node-name', nodename]
            end
            Execute::execute cmd, print_cmd: true, print_lines: true
          end
        end
      end
    end
  end
end
