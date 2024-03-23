imageURL=https://download.fedoraproject.org/pub/fedora/linux/releases/39/Cloud/x86_64/images/Fedora-Cloud-Base-39-1.5.x86_64.qcow2
imageName="Fedora-Cloud-Base-39-1.5.x86_64.qcow2"
volumeName="local-ssd"
virtualMachineId="9000"
templateName="fedora-base-39-cloud-tmpl"
tmp_cores="2"
tmp_memory="2048"
rootPasswd="D9dUFf7pxNnuLGa5smI8"
cpuTypeRequired="host"
userName="sso-user"
userPassword="L1ght5p33d"

apt update
apt install libguestfs-tools -y
rm *.qcow2
wget -O $imageName $imageURL
qm destroy $virtualMachineId
virt-customize -a $imageName --install qemu-guest-agent
virt-customize -a $imageName --root-password password:$rootPasswd
qm create $virtualMachineId --name $templateName --memory $tmp_memory --cores $tmp_cores --net0 virtio,bridge=vmbr10
qm importdisk $virtualMachineId $imageName $volumeName
qm set $virtualMachineId --scsihw virtio-scsi-pci --scsi0 $volumeName:vm-$virtualMachineId-disk-0
qm set $virtualMachineId --boot c --bootdisk scsi0
qm set $virtualMachineId --ide2 $volumeName:cloudinit
qm resize $virtualMachineId scsi0 +15G
qm set $virtualMachineId --serial0 socket --vga serial0
qm set $virtualMachineId --ipconfig0 ip=dhcp
qm set $virtualMachineId --cpu cputype=$cpuTypeRequired
qm set $virtualMachineId --agent 1
qm set $virtualMachineId --ciuser $userName
qm set $virtualMachineId --cipassword $userPassword
qm template $virtualMachineId

# Reseting VM's machine-id
# Run the following command inside the VM to reset the machine-id.

# sudo rm -f /etc/machine-id
# sudo rm -f /var/lib/dbus/machine-id

# Shutdown the VM. Then power it back on. The machine-id will be regenerated.

# If the machine-id is not regenerated you can try to fix it by running the following command.

# sudo systemd-machine-id-setup

# git config --global user.name "bradleyb"
# git config --global user.email "butlerb73@gmail.com"