namespace :tolk do
  desc "Sync Tolk with the default locale's yml file for an application"
  task :sync => :environment do
    puts "Enter Application Name:"
    name = STDIN.gets.chomp
    if app = Tolk::Application.find_by_name(name)
      puts "syncing #{app.name}"
      app.sync!
    else
      puts "Couldn't find application, trying syncing with heroku db:pull"
    end
  end

  desc "Generate yml files for all the locales defined in Tolk"
  task :dump_all => :environment do
    puts "Enter Application Name:"
    name = STDIN.gets.chomp
    if app = Tolk::Application.find_by_name(name)
      puts "dumping #{app.name}"
      app.dump_all
    else
      puts "Couldn't find application, trying syncing with heroku db:pull"
    end
  end

  desc "Imports data all non default locale yml files to Tolk"
  task :import => :environment do
    puts "Enter Application Name:"
    name = STDIN.gets.chomp
    if app = Tolk::Application.find_by_name(name)
      puts "importing #{app.name}"
      app.import_secondary_locales
    else
      puts "Couldn't find application, trying syncing with heroku db:pull"
    end
  end

  desc "Show all the keys potentially containing HTML values and no _html postfix"
  task :html_keys => :environment do
    bad_translations = Tolk::Locale.primary_locale.translations_with_html
    bad_translations.each do |bt|
      puts "#{bt.phrase.key} - #{bt.text}"
    end
  end
end
