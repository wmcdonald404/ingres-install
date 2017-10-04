We already have an appropriate KVM virtual machine with a single OS disk. We just need to add additional block devices for:

- II_SYSTEM, II_WORK, II_LOG
- II_CHECKPOINT, II_JOURNAL, II_DUMP
- II_DATABASE

DISK1: OS
/opt/ingres/system:   DISK2: II_SYSTEM, II_WORK, primary transaction log
/opt/ingres/recovery: DISK3: II_CHECKPOINT, II_JOURNAL, II_DUMP, secondary transaction log
/opt/ingres/database: DISK4: II_DATABASE

Add additional virtual block devices to the VM to make it more representative of a production installation.

1. add additional disk to the vm(s)
```
[root@management ~]# qemu-img create -f raw /var/lib/libvirt/images/{{ inventory_hostname }}-1.qcow2 2G
[root@management ~]# qemu-img create -f raw /var/lib/libvirt/images/{{ inventory_hostname }}-2.qcow2 2G
[root@management ~]# qemu-img create -f raw /var/lib/libvirt/images/{{ inventory_hostname }}-3.qcow2 2G
```

2. attach additional disks to the vm(s)
```
[root@management ~]# virsh attach-disk {{ inventory_hostname }} --source /var/lib/libvirt/images/{{ inventory_hostname }}-1.qcow2 --target vdb --persistent
[root@management ~]# virsh attach-disk {{ inventory_hostname }} --source /var/lib/libvirt/images/{{ inventory_hostname }}-2.qcow2 --target vdc --persistent
[root@management ~]# virsh attach-disk {{ inventory_hostname }} --source /var/lib/libvirt/images/{{ inventory_hostname }}-3.qcow2 --target vdd --persistent
```

3. Boot the VM (if shutdown) and format the devices (LVM would be prefered for production but for demonstration purposes this should suffice):

[root@localhost ~]# mkfs.xfs /dev/vdb
[root@localhost ~]# mkfs.xfs /dev/vdc
[root@localhost ~]# mkfs.xfs /dev/vdd

