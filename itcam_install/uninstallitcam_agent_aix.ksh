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
# 1. Uninstalling ITCAM Agent for WebSphere silent...
############################################################################################

su - wasadm -c "/optware/IBM/ITM/bin/itmcmd agent -f stop yn"
su - wasadm -c "/optware/IBM/ITM/bin/itmcmd agent -f stop ux"

chown -R root:system /optware/IBM/ITM

/optware/IBM/ITM/bin/uninstall.sh yn aix533
/optware/IBM/ITM/bin/uninstall.sh ux aix526
/optware/IBM/ITM/bin/uninstall.sh um aix526
/optware/IBM/ITM/bin/uninstall.sh ul aix526
/optware/IBM/ITM/bin/uninstall.sh uf aix526
/optware/IBM/ITM/bin/uninstall.sh ue aix536
/optware/IBM/ITM/bin/uninstall.sh r6 aix526
/optware/IBM/ITM/bin/uninstall.sh r5 aix526
/optware/IBM/ITM/bin/uninstall.sh r4 aix526
/optware/IBM/ITM/bin/uninstall.sh r3 aix526
/optware/IBM/ITM/bin/uninstall.sh r2 aix526
/optware/IBM/ITM/bin/uninstall.sh ui aix526
/optware/IBM/ITM/bin/uninstall.sh jr aix526
/optware/IBM/ITM/bin/uninstall.sh gs aix526
/optware/IBM/ITM/bin/uninstall.sh ax aix526

/optware/IBM/ITM/bin/uninstall.sh -f
