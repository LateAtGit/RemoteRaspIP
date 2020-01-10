<?php
function ip_details($IPaddress) {
    $json       = file_get_contents("http://ipinfo.io/{$IPaddress}");
    $details    = json_decode($json);
    return $details;
}

$IPaddress  =  $_SERVER['REMOTE_ADDR'];

$details    =   ip_details("$IPaddress");

date_default_timezone_set("Europe/Berlin");
//print $details->city;   
//print $details->country;  
//print $details->org;      
//print $details->hostname; 
$hostname=!empty($_GET['host'])?$_GET['host']:(!empty($details->hostname)?$details->hostname:'getip2');
file_put_contents ('./getipcaller.log', $hostname.' '.date('d/m/Y H:i:s', time())." ".$_SERVER['REMOTE_ADDR']." ($details->country)\n", FILE_APPEND);

print ($_SERVER['REMOTE_ADDR']);

?>

