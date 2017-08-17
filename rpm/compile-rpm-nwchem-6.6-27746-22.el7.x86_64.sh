#!/bin/bash

echo "You need to be root"

yum install python-devel gcc-gfortran openblas-devel openblas-serial64 openmpi-devel scalapack-openmpi-devel elpa-openmpi-devel tcsh openssh-clients which

#Download RPM files
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/g/ga-common-5.3b-14.el7.noarch.rpm
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/g/ga-openmpi-5.3b-14.el7.x86_64.rpm
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/n/nwchem-common-6.6.27746-22.el7.noarch.rpm
wget http://dl.fedoraproject.org/pub/epel/7/x86_64/n/nwchem-openmpi-6.6.27746-22.el7.x86_64.rpm

#Change permission
chmod +x *.rpm

#RPM install
rpm -ivh ga-common-5.3b-14.el7.noarch.rpm
rpm -ivh ga-openmpi-5.3b-14.el7.x86_64.rpm
rpm -ivh nwchem-common-6.6.27746-22.el7.noarch.rpm
rpm -ivh nwchem-openmpi-6.6.27746-22.el7.x86_64.rpm

# Check where nwchem-openmpi is installed.
# rpm -qi --filesbypkg nwchem-openmpi
# Normally, /usr/lib64/openmpi/bin/nwchem-openmpi/nwchem-openmpi
