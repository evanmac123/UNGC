# frozen_string_literal: true

God.watch do |w|
  w.name          = "ungc-salesforce-listener"
  w.interval      = 30.seconds

  if RAILS_ENV == "production" || RAILS_ENV == "staging"
    w.uid           = "rails"
    w.gid           = "rails"
  end

  w.pid_file      = "#{RAILS_ROOT}/pids/daemon.pid"
  w.log           = File.join(RAILS_ROOT, "log", "#{w.name}.god.log")
  w.env           = {
                      "RAILS_ENV" => RAILS_ENV,
                      "HOME" => RAILS_ROOT,
                      "PIDFILE" => "#{w.pid_file}",
                      "LOGFILE" => "#{w.log}",
                    }
  w.dir           = RAILS_ROOT
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.start         = "bundle exec rake salesforce:start_listener"

  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end
end
