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

. ${_CURDIR}/uninstallitcam/ksh/email_notify_function.ksh
. ${_CURDIR}/uninstallitcam/properties/uninstallitcam${_INTENDEDHOSTNAME}.properties

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


############################################################
# 2. Uninstall ITCAM MS silent
############################################################

cat > /tmp/a420018_itcam_MS_uninstall_responsefile.opt <<EOF
-W LogSettingUninst.logLevel=ALL
-W LogSettingUninst.consoleOut=false
### -P msFilesInstall.activeForUninstall=<value>
### -P veInstall.activeForUninstall=<value>
### -P dbInstall.activeForUninstall=<value>
### -V FORCE_UNINSTALL=<value>
-V WAS_HOSTNAME=${_HOSTNAME}.${_DOMAINNAME}
-V WAS_USER=${_WASUSER}
-V WAS_USER_PWD=${_WASPASS}
-V WAS_SOAP_PORT=8880
### -V UNINST_DB2=<value>
### -V UNINST_WAS=<value>
EOF


# stop the MS and start WAS 
/opt/ITM/IBM/itcam/WebSphere/MS/bin/am-start.sh
#/opt/ITM/IBM/itcam/WebSphere/MS/bin/am-stop.sh
/opt/ITM/IBM/itcam/WebSphere/AppServer/profiles/AppSrv01/bin/startServer.sh server1  

# uninstall itcam_MS
cd /opt/ITM/IBM/itcam/WebSphere/MS/_uninst
./uninstaller.bin \
  -silent \
  -options /tmp/a420018_itcam_MS_uninstall_responsefile.opt 




if [[ $? != 0 ]] then
  email_notify \
    "ITCAM MS Uninstall Failed..... " \
    "ITCAM MS Uninstall Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

email_notify \
  "ITCAM MS Uninstall Completed" \
  "ITCAM MS Uninstall Completed" \
  $_EMAILLIST \
  $_START

############################################################
# 3. Uninstall WebSphere Standalone Silent
############################################################

email_notify \
  "Uninstalling WebSphere Binary ..." \
  "Uninstalling WebSphere Binary ..." \
  $_EMAILLIST \
  $_START

/opt/ITM/IBM/itcam/WebSphere/AppServer/profiles/AppSrv01/bin/stopServer.sh server1 -user ${_WASUSER} -password ${_WASPASS}
/opt/ITM/IBM/itcam/WebSphere/AppServer/uninstall/uninstall -silent -OPT removeProfilesOnUninstall="true"

if [[ $? != 0 ]] then
  email_notify \
    "WebSphere Uninstall Failed..... " \
    "WebSphere Uninstall Failed..... " \
    $_EMAILLIST \
    $_START
  exit 1
fi

rm -rf /opt/ITM/IBM/itcam/WebSphere/AppServer

email_notify \
  "WebSphere Standalone Uninstall Completed" \
  "WebSphere Standalone Uninstall Completed" \
  $_EMAILLIST \
  $_START


###############################################################################################################
: << 'COMMENTEND'


COMMENTEND
###############################################################################################################
