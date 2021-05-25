
###############################################################################################
# email notification.... 
###############################################################################################

email_notify(){
  email_content=$1
  email_subject=$2
  email_list=$3
  start_time=$4

  _END=`date +%s`
  _SECONDS=`expr $_END - $start_time`
  _MM=$(expr $_SECONDS / 60)

  echo "a420018------: Email to list:  $_EMAILLIST; $email_content (Total $_MM mins)  `date`." 
  echo " "

  echo "$email_content (Total $_MM mins)  `date`. " \
    | mail -s "$email_subject (Total $_MM mins)  `date`. " $_EMAILLIST
}
