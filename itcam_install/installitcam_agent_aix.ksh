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

###############################################################################################################
: << 'COMMENTEND'

############################################################################################
# 2. Installing itcam_agent_ux
############################################################################################

rm -f /tmp/itcam_agent_yn_silent_install.txt
cat > /tmp/itcam_agent_ux_silent_install.txt <<EOF
INSTALL_ENCRYPTION_KEY=IBMTivoliMonitoringEncryptionKey
#INSTALL_FOR_PLATFORM=aix523
#INSTALL_PRODUCT=cj
#INSTALL_PRODUCT=cq
#INSTALL_PRODUCT=hd
#INSTALL_PRODUCT=ms
#INSTALL_PRODUCT=sy
#INSTALL_PRODUCT=pa
INSTALL_PRODUCT=all
EOF

############################################################################################
# 2.2. Configure itcam_agent_ux
############################################################################################

/backup/portal/itcam/itm623/Agent/AgentMultiplatform/CI62PEN/install.sh \
  -q \
  -h /optware/IBM/ITM \
  -p /tmp/itcam_agent_ux_silent_install.txt

cat > /tmp/itcam_agent_ux_silent_config.txt <<EOF
CMSCONNECT=YES
HOSTNAME=pdapmpoc04
#FIREWALL=NO
NETWORKPROTOCOL=ip.pipe
IPPIPEPORTNUMBER=1918
KDC_PARTITIONNAME=null
EOF

/optware/IBM/ITM/bin/itmcmd config \
  -A \
  -p /tmp/itcam_agent_ux_silent_config.txt ux

############################################################################################
# 3. Installing itcam_agent_yn
############################################################################################

rm -f /tmp/itcam_agent_yn_silent_install.txt
cat > /tmp/itcam_agent_yn_silent_install.txt <<EOF
INSTALL_ENCRYPTION_KEY=IBMTivoliMonitoringEncryptionKey
INSTALL_PRODUCT=all
EOF

/backup/portal/itcam/CI0ECEN_ITCAM_Agent_was_AIX/install.sh \
  -q \
  -h /optware/IBM/ITM \
  -p /tmp/itcam_agent_yn_silent_install.txt


############################################################################################
# 4. Installing itcam_agent_yn_AIX_FP0002
############################################################################################
cat > /tmp/itcam_agent_yn_AIX_FP0002_silent_install.txt <<EOF
INSTALL_ENCRYPTION_KEY=IBMTivoliMonitoringEncryptionKey
INSTALL_PRODUCT=all
EOF

/backup/portal/itcam/7.1.0-TIV-ITCAMAD_WS_AIX-FP0002/install.sh \
  -q \
  -h /optware/IBM/ITM \
  -p /tmp/itcam_agent_yn_AIX_FP0002_silent_install.txt


############################################################################################
# 5. Installing itcam_agent_yn_AIX_IF0007
############################################################################################

cat > /tmp/itcam_agent_yn_AIX_IF0007_silent_install.txt <<EOF
INSTALL_ENCRYPTION_KEY=IBMTivoliMonitoringEncryptionKey
INSTALL_PRODUCT=all
EOF

/backup/portal/itcam/7.1.0.2-TIV-ITCAMAD_WS_AIX-IF0007/install.sh \
  -q \
  -h /optware/IBM/ITM \
  -p /tmp/itcam_agent_yn_AIX_IF0007_silent_install.txt




chown -R wasadm:wsadm /optware/IBM/ITM

su - wasadm -c "/optware/IBM/ITM/bin/itmcmd agent start ux"
su - wasadm -c "/optware/IBM/ITM/bin/itmcmd agent start yn"



############################################################################################
# 5. Configure itcam_agent_yn_AIX
############################################################################################
/optware/IBM/ITM/bin/itmcmd agent -f stop yn

_INTENDEDHOSTNAME=$1

cat > /tmp/itcam_agent_tema_opt1_silent_config.txt <<EOF
configure_type=tema_configure
KYN_ALT_NODEID=${_INTENDEDHOSTNAME}
KYN_PORT=63335
EOF

cd /optware/IBM/ITM/bin;

./itmcmd config \
  -A \
  -p /tmp/itcam_agent_tema_opt1_silent_config.txt yn

cd ${_CURDIR}

/optware/IBM/ITM/bin/itmcmd agent start yn



COMMENTEND
###############################################################################################################









cat > /tmp/itcam_agent_tema_silent_config.txt <<EOF
J2EEMS_SELECT=true
DC_OFFLINE_ALLOW=no
KERNEL_HOST01=pdapmpoc01@002Ecorp@002Eadvancestores@002Ecom
PORT_KERNEL_CODEBASE01=9122
MS_AM_HOME=/opt/ITM/IBM/itcam/WebSphere/MS
AM_SOCKET_BINDIP=205@002E143@002E116@002E139
FIREWALL_ENABLED=no
PROBE_CONTROLLER_RMI_PORT=8300-8399
PROBE_RMI_PORT=8200-8299
ENABLE_TTAPI=false
KYN_CONFIG_MODE=DEFAULT
was-type=wps
KYN_ADMIN_HOST./optware/IBM/WebSphere/wp_profile=pdwpndqa01@002Eadvancestores@002Ecom
KYN_ADMIN_PORT./optware/IBM/WebSphere/wp_profile=8879
KYN_APPSRVR_ALIAS./optware/IBM/WebSphere/wp_profile=WebSphere_Portal_n04s01
KYN_CONNECT_TYPE./optware/IBM/WebSphere/wp_profile=SOAP
KYN_PROFILE_NAME./optware/IBM/WebSphere/wp_profile=wp_profile
KYN_RESPONSE_FILE_LOCATION./optware/IBM/WebSphere/wp_profile=/optware/IBM/datacollectorresponsefile@002Etxt
KYN_SAVE_RESPONSE_FILE./optware/IBM/WebSphere/wp_profile=true
KYN_USE_ALLOW_RECONFIG./optware/IBM/WebSphere/wp_profile=yes
KYN_USE_CLIENT_PROPS./optware/IBM/WebSphere/wp_profile=yes
KYN_WAS_HOME./optware/IBM/WebSphere/wp_profile=/optware/IBM/WebSphere/AppServer
KYN_WAS_SERVERS./optware/IBM/WebSphere/wp_profile=cells/pdwpndqa01Cell01/nodes/pdwpappqa04Node01/servers/WebSphere_Portal_n04s01
EOF


/optware/IBM/ITM/bin/itmcmd config \
  -A \
  -p /tmp/itcam_agent_tema_silent_config.txt yn



su - wasadm -c "stopwp;syncnode;startwp"

