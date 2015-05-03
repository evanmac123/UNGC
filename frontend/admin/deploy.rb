#!/usr/bin/env ruby
require 'open3'
require 'byebug'

deploy_env = ARGV[0]

if deploy_env != 'preview'
  puts 'Please chooose an env'
  puts 'usage: ruby deploy.rb ENV'
  exit 1
end

unless ENV['AWS_SECRET_KEY']
  puts 'please export AWS_SECRET_KEY'
  exit 1
end

host = case deploy_env
       when 'preview'
         'preview.unglobalcompact.org'
       end

command = "ssh -L 6380:localhost:6379 rails@#{host}"

stdin, stdout, stderr, wait_thr = Open3.popen3(command)
pid = wait_thr[:pid]  # pid of the started process.

system "ember deploy --environment=#{deploy_env}"

Process.kill('HUP', pid)
