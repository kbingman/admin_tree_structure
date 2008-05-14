namespace :radiant do
  namespace :extensions do
    namespace :admin_tree_structure do
      
      desc "Runs the migration of the Admin Tree Structure extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          AdminTreeStructureExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          AdminTreeStructureExtension.migrator.migrate
        end
      end
    
    end
  end
end