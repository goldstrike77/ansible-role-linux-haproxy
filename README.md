![](https://img.shields.io/badge/Ansible-haproxy-green.svg?logo=angular&style=for-the-badge)

>__Please note that the original design goal of this role was more concerned with the initial installation and bootstrapping environment, which currently does not involve performing continuous maintenance, and therefore are only suitable for testing and development purposes,  should not be used in production environments.__

>__请注意，此角色的最初设计目标更关注初始安装和引导环境，目前不涉及执行连续维护，因此仅适用于测试和开发目的，不应在生产环境中使用。__

___

<p><img src="https://raw.githubusercontent.com/goldstrike77/goldstrike77.github.io/master/img/logo/logo_haproxy.png" align="right" /></p>

__Table of Contents__

- [Overview](#overview)
- [Requirements](#requirements)
  * [Operating systems](#operating-systems)
  * [HaProxy Versions](#haproxy-versions)
- [ Role variables](#Role-variables)
  * [Main Configuration](#Main-parameters)
  * [Other Configuration](#Other-parameters)
- [Dependencies](#dependencies)
- [Example Playbook](#example-playbook)
  * [Hosts inventory file](#Hosts-inventory-file)
  * [Vars in role configuration](#vars-in-role-configuration)
  * [Combination of group vars and playbook](#combination-of-group-vars-and-playbook)
- [License](#license)
- [Author Information](#author-information)
- [Donations](#Donations)

## Overview
This Ansible role installs HaProxy on linux operating system, including establishing a filesystem structure and server configuration with some common operational features.The keepalived daemon can be used to monitor services or systems and to automatically failover to a standby if problems occur. Keepalived will configure a floating IP address that can be moved between three capable load balancers. These will each be configured to split traffic between backend web servers. If the primary load balancer goes down, the floating IP will be moved to the second load balancer automatically, keep the service availability.

## Requirements
### Operating systems
This role will work on the following operating systems:

  * CentOS 7

### HaProxy versions

The following list of supported the haproxy releases:

* 2.0

## Role variables
### Main parameters #
There are some variables in defaults/main.yml which can (Or needs to) be overridden:

##### General parameters
* `haproxy_version`: Specify the HaProxy version.

##### Listen port
* `haproxy_port_arg.haproxy_exporter`: HaProxy Exporter network communication port.
* `haproxy_port_arg.keepalived_exporter`: Keepalived exporter network communication port.
* `haproxy_port_arg.stats`: The HaProxy stats page port.

##### Log Variables
* `haproxy_syslog_server`: Defines the address list of a syslog server.
* `haproxy_syslog_port`: Defines the input port of a syslog server for access log.

##### KeepAlived Variables
* `haproxy_keepalived_dept`: A boolean value, whether provides High-Availability.
* `haproxy_keepalived_vip`: Virtual IP address.

##### System Variables
* `haproxy_arg.maxconn`: The maximum per-process number of concurrent connections.
* `haproxy_arg.retries`: The number of retries to perform on a server after a connection failure.
* `haproxy_arg.timeout_http_request`: The maximum allowed time to wait for a complete HTTP request.
* `haproxy_arg.timeout_queue`: The maximum time to wait in the queue for a connection slot to be free.
* `haproxy_arg.timeout_connect`: The maximum time to wait for a connection attempt to a server to succeed.
* `haproxy_arg.timeout_client`: The inactivity timeout on the client side for half-closed connections.
* `haproxy_arg.timeout_server`: The maximum inactivity time on the server side.
* `haproxy_arg.timeout_http_keep_alive`: The maximum allowed time to wait for a new HTTP request to appear.
* `haproxy_arg.timeout_check`: Global Check timeout.
* `haproxy_arg.options`: Global Server options.

##### Proxys Variables
* `haproxy_proxy_args`: Essential configuration sections.

##### Service Mesh
* `environments`: Define the service environment.
* `datacenter`: Define the DataCenter.
* `domain`: Define the Domain.
* `customer`: Define the customer name.
* `tags`: Define the service custom label.
* `exporter_is_install`: Whether to install prometheus exporter.
* `consul_public_register`: Whether register a exporter service with public consul client.
* `consul_public_exporter_token`: Public Consul client ACL token.
* `consul_public_http_prot`: The consul Hypertext Transfer Protocol.
* `consul_public_clients`: List of public consul clients.
* `consul_public_http_port`: The consul HTTP API port.

### Other parameters
There are some variables in vars/main.yml:

## Dependencies
- Ansible versions >= 2.8
- Python >= 2.7.5

## Example

### Hosts inventory file
See tests/inventory for an example.

    node01 ansible_host='192.168.1.10' haproxy_version='2.0'

### Vars in role configuration
Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      roles:
         - role: ansible-role-linux-haproxy
           haproxy_version: '2.0'

### Combination of group vars and playbook
You can also use the group_vars or the host_vars files for setting the variables needed for this role. File you should change: group_vars/all or host_vars/`group_name`

```yaml
haproxy_version: '2.0'
haproxy_port_arg:
  haproxy_exporter: '9101'
  keepalived_exporter: '9650'
  stats: '10089'
haproxy_syslog_server:
  - '127.0.0.1'
haproxy_syslog_port: '1514'
haproxy_keepalived_dept: true
haproxy_keepalived_vip: '10.10.10.10'
haproxy_arg:
  maxconn: '4000'
  retries: '3'
  timeout_http_request: '10s'
  timeout_queue: '10s'
  timeout_connect: '10s'
  timeout_client: '30s'
  timeout_server: '30s'
  timeout_http_keep_alive: '10s'
  timeout_check: '10s'
  options:
    - 'httplog'
    - 'dontlognull'
    - 'http-server-close'
    - 'forwardfor except 127.0.0.0/8'
    - 'redispatch'
haproxy_proxy_args:
  - name: 'k8s-api'
    port: '16443'
    syntax:
      - "frontend k8s-api"
      - "  bind 0.0.0.0:16443"
      - "  mode tcp"
      - "  option tcplog"
      - "  default_backend k8s-api"
      - "backend k8s-api"
      - "  mode tcp"
      - "  option tcp-check"
      - "  balance roundrobin"
      - "  default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100"
      - "  server k8s-api-1 10.10.10.11:6443 check"
      - "  server k8s-api-2 10.10.10.12:6443 check"
      - "  server k8s-api-3 10.10.10.13:6443 check"
environments: 'prd'
datacenter: 'dc01'
domain: 'local'
customer: 'demo'
tags:
  subscription: 'default'
  owner: 'nobody'
  department: 'Infrastructure'
  organization: 'The Company'
  region: 'China'
exporter_is_install: true
consul_public_register: true
consul_public_exporter_token: '00000000-0000-0000-0000-000000000000'
consul_public_http_prot: 'https'
consul_public_http_port: '8500'
consul_public_clients:
  - '127.0.0.1'
```

## License
![](https://img.shields.io/badge/MIT-purple.svg?style=for-the-badge)

## Author Information
Please send your suggestions to make this role better.

## Donations
Please donate to the following monero address.

    46CHVMbb6wQV2PJYEbahb353SYGqXhcdFQVEWdCnHb6JaR5125h3kNQ6bcqLye5G7UF7qz6xL9qHLDSAY3baagfmLZABz75
