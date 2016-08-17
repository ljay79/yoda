#!/bin/bash
# mysqlaccess.sh

source /yoda/bin/inc/init

TMPFILE="/tmp/mysqlaccess.sql"
TYPE=${1-2}

if [ "$TYPE" = "2" ]; then

cat >| $TMPFILE <<SQL
SELECT Grantee, TableSchema, REPLACE(GROUP_CONCAT(DISTINCT PrivilegeType ORDER BY PrivilegeType SEPARATOR ','),' ','_') AS 'Privs'
FROM (
SELECT GRANTEE AS Grantee, IFNULL(TABLE_CATALOG,'All') AS TableSchema, PRIVILEGE_TYPE AS PrivilegeType, IS_GRANTABLE AS IsGrantable, @@HostName AS ServerName, USER() AS UserName, CURRENT_TIMESTAMP() AS DateTimeStamp
FROM information_schema.user_privileges
WHERE privilege_type NOT IN ('SELECT','SHOW DATABASES','SHOW VIEW','USAGE')
UNION ALL
SELECT GRANTEE AS Grantee, TABLE_SCHEMA AS TableSchema, PRIVILEGE_TYPE AS PrivilegeType, IS_GRANTABLE AS IsGrantable, @@HostName AS ServerName, USER() AS UserName, CURRENT_TIMESTAMP() AS DateTimeStamp
FROM information_schema.schema_privileges
WHERE privilege_type NOT IN ('SELECT','SHOW DATABASES','SHOW VIEW','USAGE')
ORDER BY PrivilegeType, Grantee
) AS dt1
GROUP BY Grantee, TableSchema
SQL

mysql -N -q --password=$2 < $TMPFILE | column -t

else

cat > $TMPFILE <<SQL
SELECT GRANTEE AS Grantee, TABLE_CATALOG AS TableCatalog, 'SchemaLevelPermission' AS DbName,'' AS TableName, REPLACE(PRIVILEGE_TYPE,' ','_') AS PrivilegeType, IS_GRANTABLE AS IsGrantable, @@HostName AS ServerName, USER() AS UserName, CURRENT_TIMESTAMP() AS DateTimeStamp
FROM information_schema.user_privileges
WHERE privilege_type NOT IN ('SELECT','SHOW DATABASES','SHOW VIEW','USAGE')
UNION ALL
SELECT GRANTEE, TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, PRIVILEGE_TYPE, IS_GRANTABLE, @@HostName, USER(), CURRENT_TIMESTAMP()
FROM information_schema.table_privileges
WHERE privilege_type NOT IN ('SELECT','USAGE')
ORDER BY TableName, PrivilegeType, Grantee;
SQL

mysql -N -q --password=$2 < $TMPFILE

fi

rm -f $TMPFILE

exit 0
