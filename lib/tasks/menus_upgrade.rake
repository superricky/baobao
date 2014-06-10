namespace :db do
  desc "some menus are broken after first delete events"
  task :menus_upgrade => :environment do
    Menu.transaction do
      begin 
        Menu.where('').each do |menu|
          if menu.event.nil?
            menu.destroy!
          end
        end
      rescue => e
        puts e.message
        raise ActiveRecord::Rollback
      end
    end
  end
end