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

  desc 'Start watcher'
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        # puts fetch(:puma_pid)
        execute :bundle, :exec, :puma_doctor, "start -p #{fetch(:puma_pid)} -f #{fetch(:frequency)}"
      end
    end
  end

  desc 'Stop watcher'
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        # execute :bundle, :exec, :ruby, 'watcher.rb', 'stop'
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        # execute :bundle, :exec, :ruby, 'watcher.rb', 'restart'
      end
    end
  end

  def template_puma(from, to, role)
  [
      "lib/capistrano/templates/#{from}-#{role.hostname}-#{fetch(:stage)}.rb",
      "lib/capistrano/templates/#{from}-#{role.hostname}.rb",
      "lib/capistrano/templates/#{from}-#{fetch(:stage)}.rb",
      "lib/capistrano/templates/#{from}.rb.erb",
      "lib/capistrano/templates/#{from}.rb",
      "lib/capistrano/templates/#{from}.erb",
      "config/deploy/templates/#{from}.rb.erb",
      "config/deploy/templates/#{from}.rb",
      "config/deploy/templates/#{from}.erb",
      File.expand_path("../../templates/#{from}.rb.erb", __FILE__),
      File.expand_path("../../templates/#{from}.erb", __FILE__)
  ].each do |path|
    if File.file?(path)
      erb = File.read(path)
      upload! StringIO.new(ERB.new(erb).result(binding)), to
      break
    end
  end
end


end
