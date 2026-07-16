#!/bin/bash

VM_NAME="oracle10"
ISO_PATH="/path/to/OracleLinux-R10.iso"
DISK_PATH="$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

VBoxManage createvm --name "$VM_NAME" --ostype "Oracle_64" --register
VBoxManage modifyvm "$VM_NAME" --memory 4096 --cpus 2 --graphicscontroller vmsvga --vram 128 --nic1 nat

VBoxManage createhd --filename "$DISK_PATH" --size 20000
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$DISK_PATH"
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"

echo "VM created. Start installation manually in VirtualBox."
