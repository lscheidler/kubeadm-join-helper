# Kubeadm::Join::Helper

## Installation

    $ bundle --binstubs=bin

## Usage

### Create new token on master node and upload to s3

    $ bin/kubeadm-join-helper -u

### Join worker node

    $ bin/kubeadm-join-helper -j

#### use test as node name

    $ bin/kubeadm-join-helper -j --node-name test

#### use aws instance id as node name

    $ bin/kubeadm-join-helper -j --use-instance-id

#### use aws instance id as node name

    $ bin/kubeadm-join-helper -j --use-instance-id

#### merge additional config file in YAML format ([JoinConfiguration](https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2#hdr-Kubeadm_join_configuration_types))

    $ bin/kubeadm-join-helper -j --additional-config config.yml

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lscheidler/kubeadm-join-helper.


## License

The gem is available as open source under the terms of the [Apache 2.0 License](http://opensource.org/licenses/Apache-2.0).

