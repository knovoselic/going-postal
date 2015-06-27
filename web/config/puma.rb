#!/usr/bin/env puma
require 'pathname'

rails_root = Pathname.new(File.dirname(__FILE__)).realdirpath.join '..'
daemonize true
threads 16, 128
workers 0
environment 'production'

directory rails_root.to_s
pidfile rails_root.join('tmp', 'pids', 'puma.pid').to_s
state_path rails_root.join('tmp', 'pids', 'puma.state').to_s
stdout_redirect rails_root.join('log', 'puma.access.log').to_s, rails_root.join('log', 'puma.error.log').to_s, true
bind "unix://#{rails_root.join 'tmp', 'sockets', 'puma.sock'}"

