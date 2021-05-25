#! /usr/bin/ksh


############################################################################################
# 1. Prepare to Install: Environment checking...
############################################################################################

_HOSTNAME=`uname -n`
_INTENDEDHOSTNAME=$1
_CURDIR=`pwd`

if [[ $# != 1 ]] then
  echo Please pass intended hostname as an argument.
  exit 1
fi

echo The current hostname is: ${_HOSTNAME}, The intended hostname is: ${_INTENDEDHOSTNAME}

if [[ ${_HOSTNAME} != ${_INTENDEDHOSTNAME} ]] then
  echo Usage: installwcm.ksh ${_HOSTNAME}
  exit 1
fi

. ${_CURDIR}/installitcam/ksh/email_notify_function.ksh
. ${_CURDIR}/installitcam/properties/installitcam${_INTENDEDHOSTNAME}.properties

echo The current directory is: ${_CURDIR}

if [[ "${_INTENDEDDIR}" != "${_CURDIR}" ]] then
  echo Usage: Current directory is ${_CURDIR}. Please goto "${_INTENDEDDIR}" directory.
  exit 1
fi

echo "Are you sure to install WCM to ${_HOSTNAME} ?    (y/n)";
read  yn;

if [[ $yn != "y" ]]; then
  exit 0
fi

_START=`date +%s`


which unzip 2>/dev/null 1>/dev/null

if [[ $? = 0 ]] then
  _UNZIP=unzip
else
  _UNZIP=/usr/local/bin/unzip
fi

_START=`date +%s`


############################################################################################
# 3. Installing ITCAM MS FP7002 silent...
#    /opt/ITM/IBM/itcam/WebSphere/MS/etc/am-version.properties
#    /var/ibm/tivoli/common/CYN/logs/msg-install.log
#    /var/ibm/tivoli/common/CYN/logs/trace-install.log
############################################################################################

cat > /tmp/silentUpdate.properties <<EOF
product.location=/opt/ITM/IBM/itcam/WebSphere/MS
updates.location=/backup/portal/itcam/7.1.0-TIV-ITCAMAD_MS-FP0002/updates
####only the first MS set to true, other MSs set to false
updateDb=true
updateVe=true
migration.allowUnknownPatch=false
updateVe.wasHome=/opt/ITM/IBM/itcam/WebSphere/AppServer/profiles/AppSrv01
updateVe.was.server=server1
updateVe.was.user=itcamadmin
updateVe.was.password=password
#connection.useClientProps=true
##for ND environment
#updateVe.was.soap.host=<HOST>
#updateVe.was.soap.port=<PORT>
EOF

export JAVA_HOME=/opt/ITM/IBM/itcam/WebSphere/MS/_jvm/jre

cd /backup/portal/itcam/7.1.0-TIV-ITCAMAD_MS-FP0002
./silentUpdate.sh -prepareInstall /tmp/silentUpdate.properties


if [[ $? != 0 ]] then
  email_notify \
    "ITCAMAD MS-FP0002 -prepareInstall Failed..... " \
    "ITCAMAD MS-FP0002 -prepareInstall Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

email_notify \
  "ITCAMAD MS-FP0002 -prepareInstall Completed" \
  "ITCAMAD MS-FP0002 -prepareInstall Completed" \
  $_EMAILLIST \
  $_START

/opt/ITM/IBM/itcam/WebSphere/MS/bin/am-stop.sh

cd /backup/portal/itcam/7.1.0-TIV-ITCAMAD_MS-FP0002
cat /opt/ITM/IBM/itcam/WebSphere/MS/etc/am-version.properties
./silentUpdate.sh -install /tmp/silentUpdate.properties
/opt/ITM/IBM/itcam/WebSphere/MS/bin/klctl.sh dbtest

./silentUpdate.sh -displayInstalledUpdates

#cd /backup/portal/itcam/7.1.0-TIV-ITCAMAD_MS-FP0002
#./silentUpdate.sh -rollback /tmp/silentUpdate.properties



if [[ $? != 0 ]] then
  email_notify \
    "ITCAM MS start Failed..... " \
    "ITCAM MS start Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

email_notify \
  "ITCAM MS start Completed" \
  "ITCAM MS start Completed" \
  $_EMAILLIST \
  $_START


