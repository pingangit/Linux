#!/bin/bash - 
#===============================================================================
#
#          FILE: restore_gitlab.sh
# 
#         USAGE: ./restore_gitlab.sh 
# 
#   DESCRIPTION: restore gitlab from remote backups.
# 
#        AUTHOR: kangxiaoning495@pingan.com.cn
#  ORGANIZATION: 
#       CREATED: 2016年11月01日 16时18分07秒
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

BACKUPS_DIR=/data/backups
LOGFILE=/root/scripts/restore_error.log
gitlabctl=/usr/bin/gitlab-ctl
gitlabrake=/usr/bin/gitlab-rake
rsync=/usr/bin/rsync

# backup file on which host
RSYNC_SERVER=30.16.226.110


rsync_backups ()
{
    $rsync -azP --delete --password-file=/etc/rsyncd.passwd gitlab@${RSYNC_SERVER}::gitlab $BACKUPS_DIR
    if [ $? -eq 0 ];then
        return 0
    else
        return 1
    fi
}

get_timestamp_of_backup ()
{
    cd $BACKUPS_DIR
    timestamp=$(ls -t *gitlab_backup.tar | head -1 | awk -F"_" '{print $1}')
    echo $timestamp
}

restore_gitlab ()
{
    $gitlabctl stop unicorn
    $gitlabctl stop sidekiq
    /root/scripts/silent_restore.exp $(get_timestamp_of_backup)
}

main ()
{
    rsync_backups

    if [ $? -eq 0 ];then
        echo "$(date '+%F %T') rsync backups successfully."
        restore_gitlab

        if [ $? -eq 0 ];then
            echo "$(date '+%F %T') restore successfully."
            $gitlabctl start
        else
            echo "$(date '+%F %T') restore failed." >> $LOGFILE
        fi
    else
        echo "$(date '+%F %T') rsync backups failed." >> $LOGFILE
        exit 1
    fi
}

########################
#         main         #
########################

main
