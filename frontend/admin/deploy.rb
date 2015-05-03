#!/usr/bin/env ruby
require 'open3'
require 'byebug'



class Cmd
  attr_reader :args, :port_forward_pid

  def initialize(args)
    @args = args
  end

  def command
    args[1] || 'deploy'
  end

  def deploy_env
    args[0]
  end

  def revision
    args[2]
  end

  def run
    check_args
    run_with_forward do
      self.send command
    end
  end

  def deploy
    system "ember deploy --environment=#{deploy_env}"
  end

  def activate
    raise 'NO REVISION PROVIDED' unless revision
    system "ember deploy:activate --revision #{revision} --environment=#{deploy_env}"
  end

  def list
    system "ember deploy:list --environment=#{deploy_env}"
  end

  private

  def port_forward_cmd
    "ssh -L 6380:localhost:6379 rails@#{host}"
  end

  def check_args
    if deploy_env != 'preview'
      puts 'Please chooose an env'
      puts 'usage: ruby deploy.rb ENV'
      exit 1
    end

    unless ENV['AWS_SECRET_KEY']
      puts 'please export AWS_SECRET_KEY'
      exit 1
    end
  end

  def start_port_forward
    stdin, stdout, stderr, wait_thr = Open3.popen3(port_forward_cmd)
    @port_forward_pid = wait_thr[:pid]  # pid of the started process.
  end

  def stop_port_forward
    Process.kill('HUP', port_forward_pid)
  end

  def host
    case deploy_env
    when 'preview'
      'preview.unglobalcompact.org'
    end
  end

  def run_with_forward
    start_port_forward
    yield
    stop_port_forward
  end

end

Cmd.new(ARGV).run
