# ingress-install
Initial docs for Ingress 11 Silent Install

# Ingres pre-requisite configuration
Presumes that 3 non-OS block devices are available for Ingres consumption. See PREAMBLE.md for further information.

1. Create an Ingres user (and group)
```
[root@server ~]# useradd ingres
[root@server ~]# passwd ingres
```
2. Create appropriate mount points
```
[root@server ~]# mkdir -p /mnt/ingres/{system,recovery,data}
```
3. Mount devices
```
[root@server ~]# mount /dev/vdb /mnt/ingres/system/
[root@server ~]# mount /dev/vdc /mnt/ingres/recovery/
[root@server ~]# mount /dev/vdd /mnt/ingres/data/
```
4. Create persistent mount points by *appending* the following to /etc/fstab:
```
/dev/vdb	/mnt/ingres/system	xfs	defaults 0 0 
/dev/vdc	/mnt/ingres/recovery	xfs	defaults 0 0 
/dev/vdd	/mnt/ingres/data	xfs	defaults 0 0 
```
5. Create the appropriate Ingres subdirectories
```
[root@server ~]# mkdir -p /mnt/ingres/system/{ingres11.0,work,primary_tlog}
[root@server ~]# mkdir -p /mnt/ingres/recovery/{checkpoint,journal,dump,backup_tlog}
[root@server ~]# mkdir -p /mnt/ingres/data/{database,}
```
***Note***: the resulting directory structure looks as follows:
```
/mnt/ingres/
├── data (/dev/vdd)
│   └── database
├── recovery (/dev/vdc)
│   ├── checkpoint
│   ├── dump
│   ├── journal
│   └── backup_tlog
└── system (/dev/vdb)
    ├── ingres11.0
    ├── primary_tlog
    └── work
```
6. Change the ownership of the Ingres directories
```
[root@server ~]# chown ingres:ingres /mnt/ingres/*/*
```
7. Create the bind mount points
```
[root@server ~]# mkdir /opt/ingres/{database,checkpoint,dump,journal,backup_tlog,ingres11.0,primary_tlog,work}
```
8. Bind mount the directories into /opt/ingres to present a single unified view
```
[root@server ~]# cat >> /etc/fstab <<EOF
/mnt/ingres/data/database	 /opt/ingres/database	  none	bind	0 0 
/mnt/ingres/recovery/checkpoint	 /opt/ingres/checkpoint	  none	bind	0 0 
/mnt/ingres/recovery/dump	 /opt/ingres/dump	  none	bind	0 0 
/mnt/ingres/recovery/journal	 /opt/ingres/journal	  none	bind	0 0 
/mnt/ingres/recovery/backup_tlog /opt/ingres/backup_tlog  none	bind	0 0 
/mnt/ingres/system/ingres11.0	 /opt/ingres/ingres11.0	  none	bind	0 0 
/mnt/ingres/system/primary_tlog  /opt/ingres/primary_tlog none	bind	0 0 
/mnt/ingres/system/work		 /opt/ingres/work	  none	bind	0 0 
EOF
```

***Note***: Bind mounts are not shown in the output of the mount command. Use `findmnt` to inspect bind mounts.

5. Install pre-requisite RPMs (libaio, unzip, perl, glibc.i686, libgcc.i686, zlib.i686, libstdc++.i686)
```
[root@server ~]# yum install unzip libaio perl glibc.i686 libgcc.i686 zlib.i686 libstdc++.i686
```
***Note***: Any Yum multilib failures at this point are typically due to differing versions of the same package in different architectures in available yum repositories. Ensure that packagename.i686 has the exact same %version and %release as the corresponding x86_64 package.

6. Copy and import the Actian GPG public key used to sign their RPMs
```
[user@management ~]$ scp ingres-11.0.0-100-com-linux-rpm-x86_64-UpgradePatch15214-key.asc ingres@server:
```
```
[root@server ~]# rpm --import ~ingres/ingres-11.0.0-100-com-linux-rpm-x86_64-UpgradePatch15214-key.asc 
```
***Note***: this key can also be hosted on an internal webserver and imported directly from its HTTP URI

7. Copy the Ingres installation binaries and license file
```
[user@management ~]$ scp ingres-11.0.0-100-com-linux-rpm-x86_64-UpgradePatch15214.tgz ingres@server:
[user@management ~]$ scp license/license.xml ingres@server:license.xml
```
***Note***: The binary installer should ideally be stored in a binary artefact repository.
8. Extract the Ingres installation binaries
```
[ingres@server ~]$ tar xf ingres-11.0.0-100-com-linux-rpm-x86_64-UpgradePatch15214.tgz
```
# Ingres environment preparation
1. Create the response file
```
[ingres@server ~]$ cat > /home/ingres/installer.properties <<EOF
II_SYSTEM=/opt/ingres/ingres11.0
II_WORK=/opt/ingres/work
II_LOG_FILE=/opt/ingres/primary_tlog
II_CHECKPOINT=/opt/ingres/checkpoint
II_JOURNAL=/opt/ingres/journal
II_DUMP=/opt/ingres/dump
II_DUAL_LOG=/opt/ingres/backup_tlog
II_DATABASE=/opt/ingres/database
II_TIMEZONE_NAME=EUROPE-LONDON
II_ENABLE_SQL92=ON
II_USERID=ingres
II_GROUPID=ingres
II_CHARSET=UTF8
II_LICENSE_DIR=/home/ingres
EOF
```
# Ingres install

It should now be possible to run the full installation with the response file:

[root@server ~]# /home/ingres/ingres-11.0.0-100-com-linux-rpm-x86_64-UpgradePatch15214/express_install.sh -acceptlicense -respfile /home/ingres/installer.properties


