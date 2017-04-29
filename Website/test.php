<?php

require 'functions.php';

echo "<h1>test page</h1>";

echo '<h3>test vote</h3>';
echo '<br />';

$vote = createComment(10, 1, "test test");
echo var_dump($vote);