imageURL=https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
imageName="jammy-server-cloudimg-amd64.img"
volumeName="local-ssd"
virtualMachineId="9001"
templateName="jammy-server-cloud-tmpl"
tmp_cores="2"
tmp_memory="2048"
rootPasswd="D9dUFf7pxNnuLGa5smI8"
cpuTypeRequired="host"
userName="sso-user"
userPassword="L1ght5p33d"

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
qm set $virtualMachineId --serial0 socket --vga serial0
qm set $virtualMachineId --ipconfig0 ip=dhcp
qm set $virtualMachineId --cpu cputype=$cpuTypeRequired
qm set $virtualMachineId --agent 1
qm set $virtualMachineId --ciuser $userName
qm set $virtualMachineId --cipassword $userPassword
qm template $virtualMachineId