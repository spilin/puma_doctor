require "puma_doctor/version"
require "get_process_mem"
require 'logger'

require 'puma_doctor/doctor'

module PumaDoctor
  extend self

  attr_accessor :frequency, :pid_file, :puma_pid, :puma_pid_file, :memory_threshold, :log_file
  self.frequency                  = 10 # seconds
  self.pid_file                   = 'puma_doctor.pid'
  self.puma_pid_file              = 'puma.pid'
  self.memory_threshold           = 500 # mb
  self.log_file                   = 'puma_doctor.log'

  # attr_accessor :decrease_workers_threshold, :min_workers
  # self.decrease_workers_threshold = 5

  def start(options = {})
    doctor = Doctor.new(default_options.merge(options))
    loop do
      doctor.examine
      sleep(options[:frequency] || self.frequency)
    end
  end

  def default_options
    {
      memory_threshold: self.memory_threshold,
      puma_pid_file: self.puma_pid_file,
      puma_pid: self.puma_pid,
      log_file: self.log_file
    }
  end

end
