desc "output all the pages as a csv"
task :dump_pages, [:csv_path] => [:environment] do |t, args|
  csv_path = args[:csv_path] || 'ungc-pages.csv'

  CSV.open csv_path, 'w+' do |csv|
    csv << ['Title', 'Path', 'Display in navigation']
    Page.approved.pluck(:title, :path, :display_in_navigation).each do |row|
      csv << row
    end
  end

end
