#!/bin/bash

# INCOMPLETE

/usr/sbin/authconfig --enableldap --enableldapauth --disablenis --disablecache --ldapserver=10.10.44.14 --ldapbasedn='cn=Users,dc=MEDG,dc=LOCAL' --disableldaptls --updateall

