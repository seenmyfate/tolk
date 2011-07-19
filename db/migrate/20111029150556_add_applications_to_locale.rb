class AddApplicationsToLocale < ActiveRecord::Migration
  def self.up
    add_column :locales, :application_id, :integer
  end

  def self.down
    remove_column :locales, :application
  end
end
