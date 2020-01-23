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

require 'openssl'

require 'plugin'

require_relative 'common'

module Kubeadm
  module Join
    module Helper
      module Plugins
        # push artifact to s3
        class Update < Common
          # @!macro [attach] plugin_argument
          #   @!attribute $1
          #     $2
          plugin_argument :gpg_passphrase_id, description: 'gpg passphrase id'
          plugin_argument :type, description: 'join type', optional: true, default: 'config'

          def after_initialize
            super
    
            create_token
            encrypt_token
            update_token
          end

          def create_token
            @data = {
              type: @type
            }

            case @type
            when 'config'
              @data['apiServerEndpoint'] = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address.to_s + ':6443'
              e = Execute::execute(['kubeadm', 'token', 'create'])
              @data['token'] = e.stdout.strip
              @data['caCertHashes'] = []
              cert =  OpenSSL::X509::Certificate.new(File.read('/etc/kubernetes/pki/ca.crt'))
              @data['caCertHashes'] << 'sha256:' + Digest::SHA2.hexdigest(cert.public_key.to_der)
            else
              e = Execute::execute(['kubeadm', 'token', 'create', '--print-join-command'])
              @data['joinCommand'] = e.stdout
            end
          end
    
          # encrypt token
          def encrypt_token
            crypto = GPGME::Crypto.new armor: true, pinentry_mode: GPGME::PINENTRY_MODE_LOOPBACK, password: @gpg_passphrases[@gpg_passphrase_id]
            @encrypted_data = crypto.encrypt(JSON::dump(@data), symmetric: true)
    
            raise 'GPG data is empty' if @encrypted_data.to_s.length == 0
          end
    
          def update_token
            key = File.join( @bucket_prefix, @cluster + ".json" )
            object = @bucket.object(key)
            object_data = {
              id: @gpg_passphrase_id,
              data: @encrypted_data.read
            }
            object.put(body: JSON::dump(object_data))
          end
        end
      end
    end
  end
end
