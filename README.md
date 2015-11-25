# PumaDoctor

Inspired by ( https://github.com/schneems/puma_worker_killer ). Idea is to run
separate process as a daemon to measure puma memory and restart worker when memory
threshold reached.

## Usage

### Running from ruby code.
To run from your code:

    PumaDoctor.start(frequency: 60, memory_threshold: 2000, puma_pid: 99999)

This is not very useful in production since it blocks execution, but you can play
around with options locally. Available options with defaults are:

    frequency:          60 # Interval in seconds
    puma_pid_file:      'puma.pid' # Location of puma pid file
    memory_threshold:   4000 # Amount in MB
    log_file:           'puma_doctor.log' # Name and location of log file

### Running as a daemon.

To run as daemon you can create file with content below(Ex.: doctor.rb)

    require 'puma_doctor'
    require 'daemons'

    pid_dir = '../' # Path to directory to store pid.
    Daemons.run_proc('puma_doctor', { dir: pid_dir }) do
      PumaDoctor.start(frequency: 60, memory_threshold: 1000)
    end

Then control it with(for more details visit https://github.com/thuehlinger/daemons):

    bundle exec ruby doctor.rb start
    bundle exec ruby doctor.rb stop
    bundle exec ruby doctor.rb restart

### Using with capistrano.

Probably the easiest way to run `puma_doctor` in production is to use `capistrano`. Require script in `Capfile`:

    require 'puma_doctor/capistrano'

This will add hook to start/restart daemon on `after deploy:finished`. If you want to start/stop from capistrano manually - this tasks are available:

    cap puma_doctor:check              # Check if config file exixts on server
    cap puma_doctor:config             # Config daemon
    cap puma_doctor:restart            # Restart daemon
    cap puma_doctor:start              # Start daemon
    cap puma_doctor:stop               # Stop daemon

Available options with defaults:

    set :puma_doctor_pid, -> { File.join(shared_path, 'tmp', 'pids', 'puma_doctor.pid') }
    set :puma_doctor_frequency, 30 #seconds
    set :puma_doctor_memory_threshold, 4000 #mb
    set :puma_doctor_daemon_file, -> { File.join(shared_path, 'puma_doctor_daemon.rb') }
    set :puma_doctor_log_file, -> { File.join(shared_path, 'log', 'puma_doctor.log') }
    set :puma_pid, -> { File.join(shared_path, 'tmp', 'pids', 'puma.pid') }


### Logging

You can always see what `puma_doctor` is doing by reading logs.


## Installation

Add this line to your application's Gemfile:

    gem 'puma_doctor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install puma_doctor

## TODO

Test

## Contributing

1. Fork it ( http://github.com/spilin/puma_doctor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
