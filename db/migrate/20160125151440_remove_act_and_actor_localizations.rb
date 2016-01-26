class RemoveActAndActorLocalizations < ActiveRecord::Migration
  def change
    if Localization.table_name == 'locations'
      unless Rails.env.test?
        if Dir.exists?('app/models/localizations')
          system('rm -rf app/models/localizations')
        end
        # Remove config.autoload_paths += Dir[Rails.root.join('app', 'models', 'localizations')] from application.rb
        system("cp config/application.rb.new config/application.rb") if File.exists?('config/application.rb.new')
      end
      # Drop unused tables
      drop_table :act_localizations
      drop_table :actor_localizations
    end
  end
end
