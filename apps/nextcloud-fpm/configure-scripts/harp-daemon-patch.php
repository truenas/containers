<?php

declare(strict_types=1);

// Usage: php harp-daemon-patch.php <target> <source>
//
// https://github.com/nextcloud/app_api/issues/1129
// Copies the settings of the <source> daemon onto the <target> daemon in place,
// then unregisters <source>.
//
// AppAPI has no occ command to update a daemon, and refuses to unregister one
// that has ExApps deployed on it. Updating the row in place keeps the ExApps
// attached, as they reference the daemon by name.
//
// The <source> daemon is registered with occ first, so AppAPI itself validates
// the settings, builds the deploy config and encrypts the shared key.

use OCA\AppAPI\Service\DaemonConfigService;
use OCP\App\IAppManager;
use OCP\Server;

$target = $argv[1] ?? '';
$source = $argv[2] ?? '';
if ($target === '' || $source === '') {
	fwrite(STDERR, "Usage: php harp-daemon-patch.php <target> <source>\n");
	exit(1);
}

require_once '/var/www/html/lib/base.php';
Server::get(IAppManager::class)->loadApp('app_api');

$service = Server::get(DaemonConfigService::class);

$targetConfig = $service->getDaemonConfigByName($target);
$sourceConfig = $service->getDaemonConfigByName($source);
if ($targetConfig === null || $sourceConfig === null) {
	fwrite(STDERR, sprintf("Daemon config %s not found.\n", $targetConfig === null ? $target : $source));
	exit(1);
}

$targetConfig->setDisplayName($sourceConfig->getDisplayName());
$targetConfig->setAcceptsDeployId($sourceConfig->getAcceptsDeployId());
$targetConfig->setProtocol($sourceConfig->getProtocol());
$targetConfig->setHost($sourceConfig->getHost());
// Keys the source does not have (eg docker registries added by the user) are kept.
$targetConfig->setDeployConfig(array_replace($targetConfig->getDeployConfig(), $sourceConfig->getDeployConfig()));

if ($service->updateDaemonConfig($targetConfig) === null) {
	fwrite(STDERR, sprintf("Failed to update daemon config %s.\n", $target));
	exit(1);
}

if ($service->unregisterDaemonConfig($sourceConfig) === null) {
	fwrite(STDERR, sprintf("Failed to unregister daemon config %s.\n", $source));
	exit(1);
}

echo sprintf("Daemon config %s updated.\n", $target);
