#!/bin/sh
occ_cleanups() {
  echo '## Making sure Collabora built-in app is not installed...'
  echo 'This is known to cause issues with containerized Nextcloud.'
  remove_app richdocumentscode
}
