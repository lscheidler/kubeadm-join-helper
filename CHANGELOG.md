0.1.4 (2020-04-02)
==================

- if --node-name is set, use it in kubeadm

0.1.3 (2020-01-23)
==================

- use kubeadm config feature, so we can set additional configurations

0.1.2 (2020-01-09)
==================

- join: retry to get token, if it is missing (10 times, 10 seconds between retries)

0.1.1 (2020-01-09)
==================

- Bugfix: added aws_imds to get instance_id, which is used as node name

0.1.0 (2020-01-09)
==================

- initial release
