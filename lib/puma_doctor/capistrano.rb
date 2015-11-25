namespace :load do
  task :defaults do
    set :puma_doctor_pid, -> { File.join(shared_path, 'tmp', 'pids', 'puma_doctor.pid') }
    set :puma_doctor_frequency, 10 #seconds
    set :puma_doctor_memory_threshold, 1000 #mb
    set :puma_doctor_daemon_file, -> { File.join(shared_path, 'puma_doctor_daemon.rb') }
    set :puma_doctor_log_file, -> { File.join(shared_path, 'log', 'puma_doctor.log') }
    set :puma_pid, -> { File.join(shared_path, 'tmp', 'pids', 'puma.pid') }
  end
end

namespace :puma_doctor do
  desc 'Config daemon. Generate and send puma_doctor.rb'
  task :config do
    on roles(:app), in: :sequence, wait: 5 do
      path = File.expand_path("../daemon_template.rb.erb", __FILE__)
      if File.file?(path)
        erb = File.read(path)
        upload! StringIO.new(ERB.new(erb).result(binding)), fetch(:puma_doctor_daemon_file)
      end
    end
  end

  desc 'Start daemon'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, :exec, :ruby, fetch(:puma_doctor_daemon_file), 'start'
      end
    end
  end

  desc 'Stop daemon'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, :exec, :ruby, fetch(:puma_doctor_daemon_file), 'stop'
      end
    end
  end

  desc 'Restart daemon'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle, :exec, :ruby, fetch(:puma_doctor_daemon_file), 'restart'
      end
    end
  end

end
