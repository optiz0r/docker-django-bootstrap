#!/usr/bin/env sh
set -e

_is_celery_command () {
  local cmd="$1"; shift

  python - <<EOF
import sys
from celery.bin.celery import CeleryCommand
sys.exit(0 if '$cmd' in CeleryCommand.commands else 1)
EOF
}

if [ "$1" != 'celery' ]; then
  # If first argument looks like an option or a Celery command, add the 'celery'
  if [ "${1#-}" != "$1" ] || _is_celery_command "$1"; then
    set -- celery "$@"
  fi
fi

if [ "$1" = 'celery' ]; then
  # Run under the celery user
  set -- su-exec django "$@"

  # Celery by default writes files like pidfiles and the beat schedule file to
  # the current working directory. Change to the Celery working directory so
  # that these files end up there.
  cd /var/run/celery
fi

exec "$@"