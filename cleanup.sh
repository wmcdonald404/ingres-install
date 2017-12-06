#!/bin/sh

yum -y remove ingres.x86_64 ingres-dbms.x86_64 ingres-odbc.x86_64 ingres-net.x86_64 director.x86_64
rm -rf /opt/ingres/*/*
yum history new
