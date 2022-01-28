#!/bin/bash

systemctl stop pve-cluster.service corosync.service
pmxcfs -l
rm /etc/corosync/*
rm /etc/pve/corosync.conf
killall pmxcfs
systemctl start pve-cluster