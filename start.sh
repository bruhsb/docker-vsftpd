#!/bin/sh -ex

USERDB=/etc/vsftpd/user.db
VSFTPD_OPTIONS=${VSFTPD_OPTIONS-}
DEFAULT_OPTIONS="-oanonymous_enable=NO -ohide_ids=YES -ouser_sub_token=USER -olocal_root=/home/vftp/USER -opam_service_name=vsftpd.virtual -ovirtual_use_local_privs=YES -ovsftpd_log_file=/proc/1/fd/1 -oxferlog_std_format=NO -owrite_enable=YES -oguest_enable=YES -opasv_min_port=20000 -opasv_max_port=20100"
OVERRIDES="-obackground=NO"
LOG_STDOUT=${LOG_STDOUT-y}

main() {
    generate_userdb
    OVERRIDES="$OVERRIDES $(pasv_address_option)"
    if [ ! $LOG_STDOUT = y ]; then
        DEFAULT_OPTIONS="${DEFAULT_OPTIONS} -ovsftpd_log_file=/var/log/vsftpd.log"
    fi
    /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf $DEFAULT_OPTIONS $VSFTPD_OPTIONS $OVERRIDES
    wait $?
}

pasv_address_option() {
    if [ -n "$SERVICE_NAME" ]; then
        echo "-opasv_address=$SERVICE_NAME -opasv_addr_resolve=YES"
    fi
}

generate_userdb() {
    for entry in /etc/credentials/*; do
        if [ -f "$entry/username" -a -f "$entry/password" ]; then
            username="$(cat $entry/username)"
            password="$(cat $entry/password)"
            ftpdir=/home/vftp/$username
            if [ ! -d $ftpdir ]; then
                mkdir -p $ftpdir
                chown ftp $ftpdir
            fi

            printf "%s\n%s\n" "$username" "$password"
        else
            log "ignoring user $entry"
        fi
    done | db_load -Tt hash $USERDB
}

log() {
    echo "$@" >&2
}

main
