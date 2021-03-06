module PumaDoctor
  class Doctor
    def initialize(options = {})
      @memory_threshold = options[:memory_threshold]
      @puma_pid_file = options[:puma_pid_file]
      @puma_pid = options[:puma_pid] && options[:puma_pid].to_i
      @logger = options[:logger]
    end

    def examine
      @master_pid = get_master_pid(@master_pid)
      return if @master_pid.nil?
      workers = get_workers(@master_pid) # worker pids with size, last one is the largest one
      used_memory = workers.inject(0) {|memo, v| memo += v.last } + GetProcessMem.new(@master_pid).mb
      logger.info "[Puma Doctor] Total memory used: #{used_memory} mb. Workers online: #{workers.size}"
      if used_memory > @memory_threshold
        kill_largest_worker(workers)
      end
    end

    private

    def get_master_pid(current_puma_pid)
      if current_puma_pid && process_is_running?(current_puma_pid)
        current_puma_pid
      elsif current_puma_pid && (@puma_pid_file.nil? || !File.exists?(@puma_pid_file))
        logger.warn "[Puma Doctor] Master pid is no longer represents running process.
          Reload failed because pid file is not set or invalid(File: '#{@puma_pid_file}')"
        nil
      elsif current_puma_pid && (current_puma_pid = File.read(@puma_pid_file).to_i) && process_is_running?(current_puma_pid)
        logger.warn "[Puma Doctor] Master pid is no longer represents running process. Successfully Reloaded pid file."
        current_puma_pid
      elsif @puma_pid && process_is_running?(@puma_pid)
        current_puma_pid = @puma_pid
      elsif @puma_pid_file && File.exists?(@puma_pid_file) && process_is_running?(current_puma_pid = File.read(@puma_pid_file).to_i)
        current_puma_pid
      else
        logger.warn "[Puma Doctor] Puma master pidfile is not found"
        nil
      end
    end

    def get_workers(puma_pid)
      `pgrep -P #{puma_pid} -d ','`.split(',').compact.map do |pid|
        [pid.to_i, GetProcessMem.new(pid).mb]
      end
    end

    def kill_largest_worker(workers)
      pid, memory_used = workers.max_by {|a| a[1]}
      Process.kill('TERM', pid)
      logger.info "[Puma Doctor] Doctor killed worker(#{pid}).It was using #{memory_used} mb. Workers online: #{workers.size - 1}"
    end

    def process_is_running?(pid)
      Process.getpgid(pid)
      true
    rescue Errno::ESRCH
      false
    end

    def logger
      @logger
    end

  end
end
