namespace :pre_commit do
  task :ci do
    ENV['RAILS_ENV'] = 'test'
    Rake::Task['spec'].invoke
  end
end
