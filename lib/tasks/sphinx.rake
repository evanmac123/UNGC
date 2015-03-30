namespace :ts do

  desc "Rebuild the sphinx index using god to start and stop the index daemon"
  task rebuild_with_god: [:environment] do
    system 'sudo god stop unglobalcompact-sphinx'
    Rake::Task["ts:clear"].invoke
    Rake::Task["ts:index"].invoke
    system 'sudo god start unglobalcompact-sphinx'
  end

end
