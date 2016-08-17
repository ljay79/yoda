SELECT
nl.email AS `email`,
nl.firstname AS `first_name`,
nl.lastname AS `last_name`,
nl.engine AS `Engine`,
nl.language AS `language`,
IFNULL(nl.provisioning_id,'') AS `ProvisioningId`,
IFNULL(nld.business_name,'') AS `PartnerSite_BusinessName`,
CASE nld.region_mall
        WHEN 1 THEN 'US-en'
        WHEN 2 THEN 'US-es'
        WHEN 3 THEN 'DK-da'
        WHEN 4 THEN 'DE-de'
        WHEN 5 THEN 'ES-es'
        WHEN 6 THEN 'AU-en'
        WHEN 7 THEN 'UK-en'
        WHEN 8 THEN 'CA-en'
        WHEN 9 THEN 'IT-it'
        WHEN 10 THEN 'AT-de'
        WHEN 11 THEN 'CH-de'
        WHEN 12 THEN 'RU-ru'
        WHEN 13 THEN 'IN-en'
        WHEN 14 THEN 'GLOBAL-fr'
        WHEN 15 THEN 'GLOBAL-hu'
        WHEN 16 THEN 'GLOBAL-sl'
        WHEN 17 THEN 'GLOBAL-pt'
        WHEN 18 THEN 'GLOBAL-nl'
        WHEN 19 THEN 'GLOBAL-cs'
        WHEN 20 THEN 'GLOBAL-pl'
        WHEN 21 THEN 'RU-kk'
        WHEN 22 THEN 'GLOBAL-de'
        WHEN 23 THEN 'GLOBAL-ru'
        WHEN 24 THEN 'GLOBAL-es'
        WHEN 25 THEN 'GLOBAL-en'
        ELSE 'n/a'
END as `Mall_Language`,
IFNULL(nld.region_mall,'') AS `RegionMallId`,
nl.users_id AS `UserId_Deprecated`
FROM `nl_subscriptions` nl
LEFT JOIN `nl_subscriptions_profile_data` AS nld USING(`provisioning_id`)
WHERE
    nl.`status` = 1
;

