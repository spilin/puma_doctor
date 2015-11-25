require "puma_doctor/version"
require "get_process_mem"

require 'puma_doctor/doctor'
require 'puma_doctor/logger'

module PumaDoctor
  extend self

  attr_accessor :frequency, :pid_file, :puma_pid, :puma_pid_file, :memory_threshold, :log_file
  attr_reader :logger
  self.frequency                  = 60 # seconds
  self.pid_file                   = 'puma_doctor.pid'
  self.puma_pid_file              = 'puma.pid'
  self.memory_threshold           = 4000 # mb
  self.log_file                   = 'puma_doctor.log'

  def start(options = {})
    @logger = ::PumaDoctor::Logger.new(log_file: options[:log_file] || self.log_file, log_level: options[:log_level])
    doctor = Doctor.new(default_options.merge(options).merge(logger: @logger))
    loop do
      doctor.examine
      sleep(options[:frequency] || self.frequency)
    end
  end

  def default_options
    {
      memory_threshold: self.memory_threshold,
      puma_pid_file: self.puma_pid_file,
      puma_pid: self.puma_pid
    }
  end

end
