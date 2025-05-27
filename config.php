<?php
define('DB_SERVER', 'mysql');
define('DB_USERNAME', 'root');
define('DB_PASSWORD', 'Testing');
define('DB_NAME', 'demo_db');
$link = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_NAME);
if ($link === false) {
    die("ERROR: Could not connect. " . mysqli_connect_error());
}
