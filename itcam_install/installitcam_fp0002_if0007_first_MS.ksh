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
# 2. Installing WebSphere v7 Standalone
############################################################################################

email_notify \
  "Installing WebSphere Standalone ..." \
  "Installing WebSphere Standalone ..." \
  $_EMAILLIST \
  $_START

rm -f /tmp/responsefile_standalone_profile.txt 

cat > /tmp/responsefile_standalone_profile.txt <<EOF
-OPT silentInstallLicenseAcceptance="true"
-OPT installType="installNew"
-OPT profileType="standAlone"
-OPT feature="noFeature"
-OPT PROF_enableAdminSecurity="true"
-OPT PROF_adminUserName="${_WASUSER}"
-OPT PROF_adminPassword="${_WASPASS}"
-OPT installLocation="/opt/ITM/IBM/itcam/WebSphere/AppServer"
EOF

/backup/portal/itcam/wasv70/WAS/install \
  -options /tmp/responsefile_standalone_profile.txt \
  -silent

if [[ $? != 0 ]] then
  email_notify \
    "WebSphere Standalone Installation Failed..... " \
    "WebSphere Standalone Installation Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

/opt/ITM/IBM/itcam/WebSphere/AppServer/profiles/AppSrv01/bin/startServer.sh server1

if [[ $? != 0 ]] then
  email_notify \
    "WebSphere Standalone Startup Failed..... " \
    "WebSphere Standalone Startup Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

email_notify \
  "WebSphere Standalone Install/Startup Completed" \
  "WebSphere Standalone Install/Startup Completed" \
  $_EMAILLIST \
  $_START



############################################################################################
# 3. Installing MS / VE silent...
#    /var/ibm/tivoli/common/CYN/logs/msg-install.log
#    /var/ibm/tivoli/common/CYN/logs/trace-install.log
############################################################################################

cat > /tmp/a420018_itcam_MS_install.opt <<EOF
##
# Log Parameters
##
-V LOG_DIR="/var/ibm/tivoli/common"
##
# Install Parameters
##
-V disableOSPrereqChecking="true"
-V LICENSE_ACCEPT_BUTTON="true"
-V LICENSE_REJECT_BUTTON="false"
-W LogSetting.logLevel="ALL"
-W LogSetting.consoleOut="false"
##
-P installLocation="/opt/ITM/IBM/itcam/WebSphere/MS"
-V IS_SELECTED_INSTALLATION_TYPE="custom"
-P msFilesInstall.active="true"
-P veInstall.active="true"
-P dbInstall.active="false"
##
# VE Admin
##
-V ITCAM_SYS_USERS="${_WASUSER}"
##
# Managing Server parameters
##
-V KERNEL_HOST01="${_HOSTNAME}.${_DOMAINNAME}
-V PORT_ARCHIVE_AGENT1="9129"
-V PORT_ARCHIVE_AGENT2="9130"
-V PORT_KERNEL_CODEBASE01="9122"
-V PORT_KERNEL_RFS01="9120"
-V PORT_KERNEL_RMI01="9118"
-V PORT_MESSAGE_DISPATCHER="9106"
-V PORT_PA="9111"
-V PORT_PS="9103"
-V PORT_PS2="9104"
-V PORT_SAM="9126"
##
# Database Parameters
##
-V NEW_DB="false"
-V EXISTING_DB="true"
-V EXISTING_DB2_LOCAL="false"
-V EXISTING_DB2_REMOTE="false"
-V EXISTING_ORACLE_LOCAL="false"
-V EXISTING_ORACLE_REMOTE="true"
##
# Oracle parameters
##
-V ORACLE_SERVER="pdoradevcla03"
-V ORACLE_PORTNUMBER="1521"
#-V ORACLE_SID="itcamdev.advancestores.com"
-V ORACLE_SID="itcamdev3"
-V ORACLE_DBA_USER="NULL"
-V ORACLE_DBA_PASSWORD="NULL"
-V ORACLE_SCHEMA_USER="itcam"
-V ORACLE_SCHEMA_PASSWORD="advance1"
-V ORACLE_HOME="NULL"
-V ORACLE_SQLPLUS_USER="NULL"
-V JDBC_TYPE="type4"
-V ORACLE_JDBC="/opt/ITM/IBM/itcam/WebSphere/oracle/product/database/11.2.0.2/jdbc/lib"
##
# WebSphere parameters
##
-V NEW_WAS="false"
-V EXISTING_WAS="true"
-V WAS_BASEDIR="/opt/ITM/IBM/itcam/WebSphere/AppServer"
-V WAS_PROFILEHOME="/opt/ITM/IBM/itcam/WebSphere/AppServer/profiles/AppSrv01"
-V WAS_PROFILENAME="AppSrv01"
-V WAS_SERVER="server1"
-V WAS_CELL="${_HOSTNAME}Node01Cell"
-V WAS_NODE="${_HOSTNAME}Node01"
-V WAS_HOSTNAME="${_HOSTNAME}.${_DOMAINNAME}
-V WAS_USER="${_WASUSER}"
-V WAS_USER_PWD="${_WASPASS}"
-V WAS_ADMIN_CONSOLE_PORT="9060"
-V WAS_SOAP_PORT="8880"
##
# Post Install parameters
##
-V LAUNCH_MS="true"
EOF

#sleep 300

/backup/portal/itcam/CZE36EN_itcam_ad_backup/setup_MS_lin.bin \
  -silent \
  -is:log /tmp/a420018_itcam_MS_install_log.txt \
  -is:tempdir /tmp \
  -options /tmp/a420018_itcam_MS_install.opt

if [[ $? != 0 ]] then
  email_notify \
    "ITCAM MS install Failed..... " \
    "ITCAM MS install Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

email_notify \
  "ITCAM MS install Completed" \
  "ITCAM MS install Completed" \
  $_EMAILLIST \
  $_START

/opt/ITM/IBM/itcam/WebSphere/MS/bin/am-start.sh

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


############################################################################################
# 4. Installing ITCAM MS FP7002 silent...
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
updateVe.was.user=${_WASUSER}
updateVe.was.password=${_WASPASS}
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

############################################################################################
# 5. Installing ITCAM MS IF0007 silent...
#    /opt/ITM/IBM/itcam/WebSphere/MS/etc/am-version.properties
#    /var/ibm/tivoli/common/CYN/logs/msg-install.log
#    /var/ibm/tivoli/common/CYN/logs/trace-install.log
############################################################################################

cat > /tmp/silentUpdate.properties <<EOF
product.location=/opt/ITM/IBM/itcam/WebSphere/MS
updates.location=/backup/portal/itcam/7.1.0.2-TIV-ITCAMAD_MS-IF0007/updates
#### for IF0007, the updateDb needs to be set to false
updateDb=false
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

cd /backup/portal/itcam/7.1.0.2-TIV-ITCAMAD_MS-IF0007
./silentUpdate.sh -prepareInstall /tmp/silentUpdate.properties

if [[ $? != 0 ]] then
  email_notify \
    "ITCAMAD MS-IF0007 -prepareInstall Failed..... " \
    "ITCAMAD MS-IF0007 -prepareInstall Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

email_notify \
  "ITCAMAD MS-IF0007 -prepareInstall Completed" \
  "ITCAMAD MS-IF0007 -prepareInstall Completed" \
  $_EMAILLIST \
  $_START

/opt/ITM/IBM/itcam/WebSphere/MS/bin/am-stop.sh

cd /backup/portal/itcam/7.1.0.2-TIV-ITCAMAD_MS-IF0007
./silentUpdate.sh -install /tmp/silentUpdate.properties

cat /opt/ITM/IBM/itcam/WebSphere/MS/etc/am-version.properties
./silentUpdate.sh -displayInstalledUpdates
/opt/ITM/IBM/itcam/WebSphere/MS/bin/klctl.sh dbtest

#cd /backup/portal/itcam/7.1.0.2-TIV-ITCAMAD_MS-IF0007
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

