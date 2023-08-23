#!/bin/sh

# Ensure the necessary directories exist..
mkdir -p /etc/ldap/slapd.d
mkdir -p /var/lib/ldap
mkdir -p /var/run/slapd
touch /var/run/slapd/slapd.pid

# Set permissions on those bad boys
chown -R openldap:openldap /etc/ldap/slapd.d
chown -R openldap:openldap /var/lib/ldap
chown -R openldap:openldap /var/run/slapd
chown -R openldap:openldap /var/run/slapd.pid

# Check if configuration exists
if [ ! -f /etc/ldap/slapd.d/cn=config.ldif ]; then
    cp /tmp/base-cn=config.ldif /etc/ldap/slapd.d/base-cn=config.ldif
    /usr/local/openldap/sbin/slapadd -n 0 -F /etc/ldap/slapd.d -l /etc/ldap/slapd.d/base-cn\=config.ldif
fi

# Start slapd with the provided arguments or defaults
exec gosu openldap /usr/local/openldap/libexec/slapd "$@"

