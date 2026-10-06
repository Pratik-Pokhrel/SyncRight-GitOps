#!/usr/bin/bash

# Owner : Pratik Pokhrel
# Description : This script confirms that this node is actually ready for kubeadm
# Date Created : 2026/09/29

set -euo pipefail
PEER_IP="${1:?Usage: ./preflight-check.sh <peer-host-only-ip>}"
HOSTONLY_PREFIX="192.168.56."
FAIL=0

check() {
	local desc="$1"; local cmd="$2"
	if eval "$cmd" &>/dev/null; 
	then
		echo " [OK] $desc"
	else
		echo " [FAIL] $desc"
		FAIL=1
	fi
}
echo "== Swap =="
check "swap is off" '[ "$(swapon --show)" = "" ]'
echo "== Container Runtime =="
check "containerd uses the systemd cgroup driver" 'grep -q "SystemdCgroup = true" /etc/containerd/config.toml'
echo "== Kubernetes tooling =="
check "kubelet installed" 'command -v kubelet'
check "kubeadm installed" 'command -v kubeadm'
check "kubelet node-ip is pinned to the Host-Only network" 'grep -q -- "--node-ip=${HOSTONLY_PREFIX}" /etc/default/kubelet'
echo "== Network =="
check "this node has a Host-Only IP (${HOSTONLY_PREFIX}x)" 'ip -4 -o addr show | grep -q "inet ${HOSTONLY_PREFIX}"'
check "both nodes are in /etc/hosts" 'grep -q k8s-control /etc/hosts && grep -q k8s-worker /etc/hosts'
check "peer node ($PEER_IP) is reachable over Host-Only" 'ping -c 2 -W 2 "$PEER_IP"'
check "internet is reachable through the NAT adapter" 'ping -c 1 -W 2 1.1.1.1'

echo

if [ "$FAIL" -eq 0 ];
then
	echo "All checks were passed, safe to proceed with kubeadm"
else
	echo "One or more checks failed, fix the items before running kubeadm"
	exit 1
fi


