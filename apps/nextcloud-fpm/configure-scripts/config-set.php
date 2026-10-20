<?php

declare(strict_types=1);

// Usage: php config-set.php <config file> <key> <value> [<key> <value>...]
//
// Sets top-level string values in a nextcloud config.php, without occ.
//
// The values are passed as arguments, so they need no escaping, and only the
// keys are printed, as some values are secrets (eg the database password).
//
// The file is written in place under a lock, the same way nextcloud does it,
// instead of being replaced, so it also works when config.php is mounted.

$file = $argv[1] ?? '';
$pairs = array_slice($argv, 2);
if ($file === '' || count($pairs) === 0 || count($pairs) % 2 !== 0) {
	fwrite(STDERR, "Usage: php config-set.php <config file> <key> <value> [<key> <value>...]\n");
	exit(1);
}

if (!is_file($file)) {
	fwrite(STDERR, sprintf("Config file %s does not exist.\n", $file));
	exit(1);
}

$CONFIG = null;
include $file;
if (!is_array($CONFIG)) {
	fwrite(STDERR, sprintf("Config file %s does not define \$CONFIG.\n", $file));
	exit(1);
}

foreach (array_chunk($pairs, 2) as [$key, $value]) {
	$CONFIG[$key] = $value;
	echo sprintf("Updating %s in %s\n", $key, $file);
}

$content = "<?php\n\$CONFIG = " . var_export($CONFIG, true) . ";\n";
if (file_put_contents($file, $content, LOCK_EX) !== strlen($content)) {
	fwrite(STDERR, sprintf("Failed to write config file %s.\n", $file));
	exit(1);
}
