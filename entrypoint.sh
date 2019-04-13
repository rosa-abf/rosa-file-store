#!/bin/sh
set -ex

if [ -f /MIGRATE ]
then
	bundle exec rake db:migrate
	rm /MIGRATE
fi
bundle exec rake assets:precompile

mkdir -p tmp/sockets
bundle exec puma -b unix:///file_store/tmp/sockets/file_store.sock -e production -t 8:16 --preload
