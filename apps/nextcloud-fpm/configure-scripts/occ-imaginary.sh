#!/bin/sh

occ_imaginary_install() {
  echo '## Configuring Imaginary...'
  occ config:system:set preview_imaginary_url --value="${IX_IMAGINARY_URL:?"IX_IMAGINARY_URL is unset"}"
}

occ_imaginary_remove() {
  echo '## Removing Imaginary Configuration...'
  occ config:system:delete preview_imaginary_url
}
