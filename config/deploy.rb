# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'mealyzer-study'

#set :repo_url, 'git@example.com:me/my_repo.git'
set :repo_url, 'git@github.com:hooverlunch/mealyzer.git'

set :use_sudo, false

# set rails env to stage name
set :rails_env, -> {fetch(:stage)}

set :deploy_to, -> {"/home/tomsmyth/webapps/rails4/mealyzer_study"}

# needed to avoid execution permission errors
set :tmp_dir, -> {"/home/tomsmyth/tmp"}

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/railsenv config/initializers/turkee.rb .env}

# Default value for linked_dirs is []
set :linked_dirs, %w{public/system public/uploads}

# Default value for default_env is {}
set :default_env, {
  path: "$PATH:$HOME/bin:$HOME/webapps/rails4/bin",
  gem_home: "$HOME/webapps/rails4/gems",
  pgoptions: "'-c statement_timeout=0'"
}

# This is so that both staging and production can have crontab entries.
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "/home/tomsmyth/webapps/rails4/bin/restart"
    end
  end

  after :publishing, :restart

  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app), in: :sequence, wait: 1 do
      unless `git rev-parse #{fetch(:branch)}` == `git rev-parse origin/#{fetch(:branch)}`
        puts "FATAL: Local '#{fetch(:branch)}' branch HEAD is not the same as origin."
        exit
      end
    end
  end

  before :starting, :check_revision

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

end
