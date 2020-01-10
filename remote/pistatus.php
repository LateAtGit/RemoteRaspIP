<html>
<head><title>PiStatus</title></head>
<body class="font-size:25px;">
<?php
  $rpilist = [
	'Raspi1',
	'Raspi2',
	'Raspi3',
	'Raspi4',
  ];
  foreach ($rpilist as $rpiname) {
    ob_start();
    $command="grep $rpiname getipcaller.log | tail -1 | cut -d ' ' -f2-3";
    system($command , $return_var);
    $output = ob_get_contents();
    if (empty($output)) {
      $output = "<span style='color: #ff0000;'>Offline</span>";
    }
    ob_end_clean();
    print $rpiname . ' ' . $output . "<br/>";
  }
?>
</body>
