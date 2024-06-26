#!/bin/sh

set -e

exec dumb-init -- npm run start:dev
