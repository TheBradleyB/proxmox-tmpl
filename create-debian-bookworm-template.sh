imageURL=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2
imageName="debian-12-genericcloud-amd64.qcow2"
volumeName="local-ssd"
virtualMachineId="9002"
templateName="debain-12-cloud-tmpl"
tmp_cores="2"
tmp_memory="2048"
rootPasswd="D9dUFf7pxNnuLGa5smI8"
cpuTypeRequired="host"
userName="sso-user"
userPassword="L1ght5p33d"
sshkeys_pub="/root/.ssh/id_ed25519-butlerlab-ssh.pub"


apt update
apt install libguestfs-tools -y
rm *.qcow2
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
qm set $virtualMachineId --sshkeys $sshkeys_pub
qm set $virtualMachineId --ciuser $userName
qm set $virtualMachineId --cipassword $userPassword
qm template $virtualMachineId