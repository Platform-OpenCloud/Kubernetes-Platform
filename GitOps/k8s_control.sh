echo '======== [4] Rocky Linux 기본 설정 ========'
echo '======== [4-1] 패키지 업데이트 ========'
# 강의와 동일한 실습 환경을 유지하기 위해 Linux Update 주석 처리
# dnf -y update

echo '======== [4-2] 타임존 설정 ========'
timedatectl set-timezone Asia/Seoul

echo '======== [4-3] Disk 확장 / Bug: soft lockup 설정 추가========'
dnf install -y cloud-utils-growpart
# device/vda는 VM마다 다르니, 파티션 확인 필요
growpart /dev/vda 4

# 파일 시스템 확장
xfs_growfs /

echo 0 > /proc/sys/kernel/hung_task_timeout_secs
echo "kernel.watchdog_thresh = 20" >> /etc/sysctl.conf

echo '======== [4-4] [WARNING FileExisting-tc]: tc not found in system path 로그 관련 업데이트 ========'
dnf install -y dnf-utils iproute-tc

echo '======= [4-4] hosts 설정 =========='
cat << EOF >> /etc/hosts
10.0.0.30 control
EOF

echo '======== [5] kubeadm 설치 전 사전작업 ========'
echo '======== [5] 방화벽 해제 ========'
systemctl stop firewalld && systemctl disable firewalld

echo '======== [5] Swap 비활성화 ========'
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab


echo '======== [6] 컨테이너 런타임 설치 ========'
echo '======== [6-1] 컨테이너 런타임 설치 전 사전작업 ========'
echo '======== [6-1] iptable 세팅 ========'
cat <<EOF |tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF |tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo '======== [6-2] 컨테이너 런타임 (containerd 설치) ========'
echo '======== [6-2-1] containerd 패키지 설치 (option2) ========'
echo '======== [6-2-1-1] docker engine 설치 ========'
echo '======== [6-2-1-1] repo 설정 ========'
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

echo '======== [6-2-1-1] containerd.io 설치 가능한 리스트 확인 ========'
dnf list containerd.io --showduplicates | sort -r

echo '======== [6-2-1-1] containerd 설치 ========'
dnf install -y containerd.io-1.7.25-3.1.el9
systemctl daemon-reload
systemctl enable --now containerd

echo '======== [6-3] 컨테이너 런타임 : cri 활성화 ========'
# defualt cgroupfs에서 systemd로 변경 (kubernetes default는 systemd)
containerd config default > /etc/containerd/config.toml
sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd



echo '======== [7] kubeadm 설치 ========'
echo '======== [7] repo 설정 ========'
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
EOF
# exclude는 제외할 패키지를 설정하는 것이다. kubelet, kubeadm, kubectl 패키지를 제외하고 설치하겠다는 의미이다.
# exclude=kubelet kubeadm kubectl


echo '======== [7] SELinux 설정 ========'
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo '======== [7] kubelet, kubeadm, kubectl 패키지 설치 ========'
# repo에서 kubeadm, kubelet, kubectl 패키지 리스트를 확인
dnf list kube*
dnf install -y kubelet-1.32.0-150500.1.1.x86_64 kubeadm-1.32.0-150500.1.1.x86_64 kubectl-1.32.0-150500.1.1.x86_64 --disableexcludes=kubernetes
systemctl enable --now kubelet

SHELL



$install_master = <<-SHELL

echo '======== [8] kubeadm으로 클러스터 생성  ========'
echo '======== [8-1] 클러스터 초기화 (Pod Network 세팅) ========'
kubeadm init --pod-network-cidr=20.96.0.0/12 --apiserver-advertise-address 10.0.0.30

echo '======== [8-2] kubectl 사용 설정 ========'
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo '======== [8-3] Pod Network 설치 (calico) ========'
kubectl create -f https://raw.githubusercontent.com/Cloud-Web-Platform/Atlas-PlayGround/refs/heads/develop/GitOps/k8s-1.32/calico-3.29.1/calico.yaml
kubectl create -f https://raw.githubusercontent.com/Cloud-Web-Platform/Atlas-PlayGround/refs/heads/develop/GitOps/k8s-1.32/calico-3.29.1/calico-custom.yaml


echo '======== [9] 쿠버네티스 편의기능 설치 ========'
echo '======== [9-1] kubectl 자동완성 기능 ========'
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

echo '======== [9-2] Dashboard 설치 ========'
kubectl create -f https://raw.githubusercontent.com/k8s-1pro/install/main/ground/k8s-1.27/dashboard-2.7.0/dashboard.yaml

echo '======== [9-3] Metrics Server 설치 ========'
kubectl create -f https://raw.githubusercontent.com/Cloud-Web-Platform/Atlas-PlayGround/refs/heads/develop/GitOps/k8s-1.32/metrics-server-0.7.2/components.yaml
SHELL
