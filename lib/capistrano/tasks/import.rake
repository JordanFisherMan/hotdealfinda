namespace :import do
  desc 'run import fetch thor task'
  task :fetch do
    on roles(:all) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :thor, 'import:fetch'
        end
      end
    end
  end

  desc 'run import remove expired deals thor task'
  task :remove_expired_deals do
    on roles(:all) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :thor, 'import:remove_expired_deals'
        end
      end
    end
  end
end
