#!/usr/local/bin/php
<?
$file = file_get_contents($argv[1]);
if( strstr($file,'var ') !== FALSE ) {
//	file_put_contents($argv[1],preg_replace('/(?<!"|\')(function)/',"\nfunction",$file));
	file_put_contents($argv[1],preg_replace('/(?<!"|\'|[a-zA-Z0-9])(function)(?=\s|\()/',"\n$1",$file));
} else {
	file_put_contents($argv[1],preg_replace('/}/',"}\n",$file));
}
?>
