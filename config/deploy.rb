require 'capistrano/ext/multistage'
# require 'bundler/capistrano'

set :application, :tcp_staffing
set :repository,  "git@github.com:GSA-OCSIT/myusa-tasks.git"
set :user, "ubuntu"
set :deploy_to, "/www/myusa-admin-tasks"
set :rvm_type, :user
set :keep_releases, 5

##-- capistrano-ext settings
set :stages, ["uat", "production"]
set :default_stage, "uat"

# Set for the password prompt
# https://help.github.com/articles/deploying-with-capistrano
default_run_options[:pty] = true

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "myusa-admin-tasks"      # Your HTTP server, Apache/etc
role :app, "myusa-admin-tasks"      # This may be the same as your `Web` server

namespace :deploy do
  desc "chown & chmod"
  task :chown do
    sudo "chown -R ubuntu #{deploy_to}"
    sudo "chmod -R 775 #{deploy_to}"
  end
end

namespace :db do
  desc "Make symlink for database yaml"
  task :symlink_db do
    run "ln -nfs #{deploy_to}/shared/database.yml #{deploy_to}/current/config/database.yml"
  end
end

namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "/etc/init.d/apache2 #{action.to_s}", :via => run_method
    end
  end
end

after 'deploy:setup', 'deploy:chown'
after "deploy:restart", "deploy:cleanup"
after "deploy:restart", "db:symlink_db"
after "db:symlink_db", "apache:restart"
after "apache:restart", "deploy:cleanup"

