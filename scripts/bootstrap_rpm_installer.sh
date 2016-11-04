#!/bin/bash

echo s3 location of RPM and EBF
export S3_LOCATION_RPM=s3://bdm-awsmarketplace

echo Temp location to extract the RPM
export TEMP_DIR=/tmp/temp_infa

echo Default location to install Informatica RPM
export INFA_RPM_INSTALL_HOME=/opt/Informatica

echo Extracting the prefix part from the rpm file name
echo The rpm installer name would be InformaticaHadoop-10.1.0-1.364.x86_64.tar.gz
export INFA_RPM_FILE_PREFIX=InformaticaHadoop-10.1.0-1.364

echo Extracting the prefix part from the ebf file name
echo The ebf rpm installer name would be EBF17557_HadoopEBF.x86_64.tar.gz
export INFA_RPM_EBF_PREFIX=EBF17557_HadoopEBF

echo S3_LOCATION_RPM = $S3_LOCATION_RPM
echo TEMP_DIR = $TEMP_DIR
echo INFA_RPM_INSTALL_HOME = $INFA_RPM_INSTALL_HOME
echo INFA_RPM_FILE_PREFIX = $INFA_RPM_FILE_PREFIX
echo INFA_RPM_EBF_PREFIX = $INFA_RPM_EBF_PREFIX

echo  Installing the RPM:
echo "Creating temporary folder for rpm extraction"
sudo mkdir -p $TEMP_DIR
cd $TEMP_DIR/
echo "current directory =" $(pwd)

echo Getting RPM installer
echo Copying the rpm installer $S3_LOCATION_RPM/$INFA_RPM_FILE_PREFIX.x86_64.tar.gz to $(pwd)
sudo aws s3 cp $S3_LOCATION_RPM/$INFA_RPM_FILE_PREFIX.x86_64.tar.gz .
sudo tar -zxvf $INFA_RPM_FILE_PREFIX.x86_64.tar.gz
cd $INFA_RPM_FILE_PREFIX
echo Installing RPM to $INFA_RPM_INSTALL_HOME
echo Running rpm2cpio command
sudo rpm2cpio InformaticaHadoop-10.1.0-1.x86_64.rpm | sudo cpio -idmv
sudo mkdir $INFA_RPM_INSTALL_HOME
cd opt/
sudo mv Informatica/* $INFA_RPM_INSTALL_HOME/
echo Contents of $INFA_RPM_INSTALL_HOME
echo $(ls $INFA_RPM_INSTALL_HOME)

echo chmod
cd $INFA_RPM_INSTALL_HOME
sudo chmod 777 -R $INFA_RPM_INSTALL_HOME
echo removing temporary folder
sudo rm -rf $TEMP_DIR/

echo Applying the EBF:
echo Creating temporary folder
sudo mkdir -p $TEMP_DIR
cd $TEMP_DIR/
echo Getting EBF installer
sudo aws s3 cp $S3_LOCATION_RPM/"$INFA_RPM_EBF_PREFIX"_EBFInstaller.tar .
echo Applying EBF installer to $INFA_RPM_INSTALL_HOME
sudo tar -xvf "$INFA_RPM_EBF_PREFIX"_EBFInstaller.tar
cd $INFA_RPM_EBF_PREFIX
sudo -S ./InformaticaHadoopEBFInstall.sh <<< $1$'\nYes\n1\n'

echo chmod
cd $INFA_RPM_INSTALL_HOME
sudo chmod 777 -R $INFA_RPM_INSTALL_HOME
echo Removing temporary folder
sudo rm -rf $TEMP_DIR/

echo done
