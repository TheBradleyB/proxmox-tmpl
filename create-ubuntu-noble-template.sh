imageURL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
imageName="noble-server-cloudimg-amd64.img"
volumeName="local-ssd"
virtualMachineId="9003"
templateName="cloud-ubuntu-noble-tmpl"
tmp_cores="2"
tmp_memory="2048"
rootPasswd="D9dUFf7pxNnuLGa5smI8"
cpuTypeRequired="host"
userName="sso-user"
sshkeys_pub="/root/.ssh/id_ed25519-butlerlab-ssh.pub"

apt update
apt install libguestfs-tools -y
rm *.img
wget -O $imageName $imageURL
qm destroy $virtualMachineId
virt-customize -a $imageName --install qemu-guest-agent
virt-customize -a $imageName --root-password password:$rootPasswd
virt-customize -a $imageName --truncate /etc/machine-id
qm create $virtualMachineId --name $templateName --memory $tmp_memory --cores $tmp_cores --net0 virtio,bridge=vmbr10
qm importdisk $virtualMachineId $imageName $volumeName
qm set $virtualMachineId --scsihw virtio-scsi-pci --scsi0 $volumeName:vm-$virtualMachineId-disk-0
qm set $virtualMachineId --boot c --bootdisk scsi0
qm set $virtualMachineId --ide2 $volumeName:cloudinit
qm resize $virtualMachineId scsi0 +18G
qm set $virtualMachineId --serial0 socket --vga serial0
qm set $virtualMachineId --ipconfig0 ip=dhcp
qm set $virtualMachineId --cpu cputype=$cpuTypeRequired
qm set $virtualMachineId --agent 1
qm set $virtualMachineId --ciuser $userName
qm set $virtualMachineId --sshkeys $sshkeys_pub
qm template $virtualMachineId