module Tolk
  class Application < ActiveRecord::Base
    set_table_name 'tolk_applications'
    has_many :phrases, :class_name => 'Tolk::Phrase'
    has_many :locales, :class_name => 'Tolk::Locale'
    has_many :translations, :class_name => 'Tolk::Translation'
  
    def secondary_locales
        locales - [Tolk::Locale.primary_locale]
    end
  end
end
