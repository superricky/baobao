desc "reload member fix data"
task :recover_members_table => :environment do |t, args|
  unless ActiveRecord::Base.connection.table_exists? 'members'
    begin
      ActiveRecord::Base.connection.execute(IO.read("#{Rails.root}/lib/members_structure.sql"))
      ActiveRecord::Base.connection.execute(IO.read("#{Rails.root}/lib/member_data.sql"))
    rescue Exception => e
      ActiveRecord::Migration.drop_table(:members)
      raise e
    end
  end
end