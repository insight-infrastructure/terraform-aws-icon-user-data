
data "template_file" "nat" {
  template = <<-EOT
echo ${var.vpc_cidr} >> /testing.txt
echo ${var.nlb_dns} >> /testing.txt
EOT
}

//iptables -t nat -A POSTROUTING -o ens3 -s ${var.vpc_cidr} -j MASQUERADE
//%{ if var.nlb_dns != "" }
//for ip in `getent hosts ${var.nlb_dns} | awk '{ print $1 }'`
//do
//  iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 9000 -j DNAT --to $ip:9000
//  iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 7100 -j DNAT --to $ip:7100
//done
//%{ endif }

//ip route add 10.0.0.0/16 dev ens3
//sysctl -w net.ipv4.ip_forward=1
//iptables -t nat -A POSTROUTING ! -d 10.0.0.0/16 -o ens3 -j SNAT --to-source 1.2.3.4



//for ip in `getent hosts nlb.us-east-1.icon.internal | awk '{ print $1 }'`
//do
//  sudo iptables -A PREROUTING -t nat -i ens3 -p tcp --dport 80 -j DNAT --to $ip:9000
//  sudo iptables -A FORWARD -p tcp -d $ip --dport 9000 -j ACCEPT
//  sudo iptables -A PREROUTING -t nat -i ens3 -p tcp --dport 80 -j DNAT --to $ip:7100
//  sudo iptables -A FORWARD -p tcp -d $ip --dport 7100 -j ACCEPT
//done
//sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9000 -j DNAT --to $ip:9000
//sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 7100 -j DNAT --to $ip:7100


//data "template_file" "nat" {
//  template = <<-EOT
//#!/bin/sh
//echo 1 > /proc/sys/net/ipv4/ip_forward
//
//iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -j MASQUERADE
//' | sudo tee /etc/network/if-pre-up.d/nat-setup
//sudo chmod +x /etc/network/if-pre-up.d/nat-setup
//sudo /etc/network/if-pre-up.d/nat-setup
//
//iptables -t nat -A POSTROUTING -o eth0 -s ${var.vpc_cidr} -j MASQUERADE
//iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9000 -j DNAT --to ${var.nlb_dns}:9000
//iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 7100 -j DNAT --to ${var.nlb_dns}:7100
//
//EOT
//}

//#cloud-config
//# -*- YAML -*-
//apt_upgrade: true
//locale: en_US.UTF-8
//packages:
// - traceroute
// - nmap
// - keepalived
//write_files:
//-   path: /lib/systemd/system/awsnycast.service
//    content: |
//        [Unit]
//        Description=Job that runs AWSnycast
//        [Service]
//        Type=simple
//        ExecStart=/usr/bin/AWSnycast
//-   path: /etc/awsnycast.yaml
//    content: |
//        ---
//        poll_time: 300
//        healthchecks:
//            public:
//                type: ping
//                destination: 8.8.8.8
//                rise: 2
//                fall: 10
//                every: 1
//        routetables:
//             my_az:
//                find:
//                    type: subnet
//                    config:
//                        subnet_id: ${mysubnet}
//                manage_routes:
//                   - cidr: 0.0.0.0/0
//                     instance: SELF
//                     healthcheck: public
//                     never_delete: true
//             other_azs:
//                find:
//                    type: and
//                    config:
//                        filters:
//                          - type: subnet
//                            not: true
//                            config:
//                                subnet_id: ${mysubnet}
//                          - type: by_tag_regexp
//                            config:
//                                key: Name
//                                regexp: ${name}-${identifier}-${region}[a-z]
//                manage_routes:
//                  - cidr: 0.0.0.0/0
//                    instance: SELF
//                    healthcheck: public
//                    if_unhealthy: true
//# The commands below need to run on every boot, but bootcmd runs too early,
//# before the write_files has run, but on every boot, where as runcmd only runs
//# on the first time this instance is booted.
//bootcmd:
//  - [ sh, -c, "[ -x /var/lib/cloud/instance/scripts/runcmd ] && /var/lib/cloud/instance/scripts/runcmd" ]
//runcmd:
// - [ sh, -c, "echo 1 > /proc/sys/net/ipv4/ip_forward;echo 655361 > /proc/sys/net/netfilter/nf_conntrack_max" ]
// - [ iptables, -N, LOGGINGF ]
// - [ iptables, -N, LOGGINGI ]
// - [ iptables, -A, LOGGINGF, -m, limit, --limit, 2/min, -j, LOG, --log-prefix, "IPTables-FORWARD-Dropped: ", --log-level, 4 ]
// - [ iptables, -A, LOGGINGI, -m, limit, --limit, 2/min, -j, LOG, --log-prefix, "IPTables-INPUT-Dropped: ", --log-level, 4 ]
// - [ iptables, -A, LOGGINGF, -j, DROP ]
// - [ iptables, -A, LOGGINGI, -j, DROP ]
// - [ iptables, -A, FORWARD, -s, ${vpc_cidr}, -j, ACCEPT ]
// - [ iptables, -A, FORWARD, -j, LOGGINGF ]
// - [ iptables, -P, FORWARD, DROP ]
// - [ iptables, -I, FORWARD, -m, state, --state, "ESTABLISHED,RELATED", -j, ACCEPT ]
// - [ iptables, -t, nat, -I, POSTROUTING, -s, ${vpc_cidr}, -d, 0.0.0.0/0, -j, MASQUERADE ]
// - [ iptables, -A, INPUT, -s, ${vpc_cidr}, -j, ACCEPT ]
// - [ iptables, -A, INPUT, -p, tcp, --dport, 22, -m, state, --state, NEW, -j, ACCEPT ]
// - [ iptables, -I, INPUT, -m, state, --state, "ESTABLISHED,RELATED", -j, ACCEPT ]
// - [ iptables, -I, INPUT, -i, lo, -j, ACCEPT ]
// - [ iptables, -A, INPUT, -j, LOGGINGI ]
// - [ iptables, -P, INPUT, DROP ]
// - [ sh, -c, "which AWSnycast || { cd /tmp && wget ${awsnycast_deb_url} && dpkg -i awsnycast_*.deb && rm *.deb; }" ]
// - [ systemctl, start, awsnycast ]

