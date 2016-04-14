#!/bin/sh -ex

USERDB=/etc/vsftpd/user.db
VSFTPD_OPTIONS=${VSFTPD_OPTIONS-}
DEFAULT_OPTIONS="-oanonymous_enable=NO -ohide_ids=YES -ouser_sub_token=USER -olocal_root=/home/vftp/USER -opam_service_name=vsftpd.virtual -ovirtual_use_local_privs=YES -ovsftpd_log_file=/var/log/vsftpd.log -oxferlog_std_format=NO -ochroot_local_user=NO -owrite_enable=YES -oguest_enable=YES"
OVERRIDES="-obackground=NO"
LOG_STDOUT=${LOG_STDOUT-y}

main() {
    generate_userdb
    if [ $LOG_STDOUT = y ]; then
        rm -f /var/log/vsftpd.log
        mkfifo /var/log/vsftpd.log
        cat /var/log/vsftpd.log &
    fi
    exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf $DEFAULT_OPTIONS $VSFTPD_OPTIONS $OVERRIDES
}

generate_userdb() {
    for entry in /etc/credentials/*; do
        if [ -f "$entry/username" -a -f "$entry/password" ]; then
            username="$(cat $entry/username)"
            password="$(cat $entry/password)"
            printf "%s\n%s\n" "$username" "$password"
            mkdir -p /home/vftp/$username
        else
            log "ignoring user $entry"
        fi
    done | db_load -Tt hash $USERDB
}

log() {
    echo "$@" >&2
}

main
