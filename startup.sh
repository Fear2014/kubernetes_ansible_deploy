#!/bin/bash
ansible-playbook /etc/ansible/01.prepare.yml
ansible-playbook /etc/ansible/02.etcd.yml
ansible-playbook /etc/ansible/03.kube-master.yml
ansible-playbook /etc/ansible/04.kube-node.yml
ansible-playbook /etc/ansible/05.plugin.yml
