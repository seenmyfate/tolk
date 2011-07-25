module Tolk
  class Application < ActiveRecord::Base
    set_table_name 'tolk_applications'
    has_many :phrases, :class_name => 'Tolk::Phrase'
    has_many :locales, :class_name => 'Tolk::Locale'
    has_many :translations, :class_name => 'Tolk::Translation'
    after_create :add_starting_point_locales

    def secondary_locales
      locales - [Tolk::Locale.primary_locale]
    end

    def sync!
      sync_phrases(load_translations)
    end

    def dump_app
      puts "Not implemented - download from web interface"
      #Tolk::Locale.dump_all
    end

    def import_secondary_locales
      #Tolk::Locale.import_secondary_locales
    end

    def primary_locale_name
      'en'
    end

    def locales_config_path
      "#{Rails.root}/lib/translations"
    end

    def en_translations
      #hardcoded..english will always be the first locale
      translations.where(:locale_id => 1)
    end

    private

    def add_starting_point_locales
      for locale in Tolk::Locale.starting_point_locales
        Tolk::Locale.create(:name => locale, :application_id => self.id)
      end
    end

    def load_translations
      I18n.available_locales # force load
      english_translations = flat_hash(i18n_hash)
      filter_out_i18n_keys(english_translations.merge(read_primary_locale_file))
    end

    def read_primary_locale_file
      primary_file = "#{locales_config_path}/#{name}/#{primary_locale_name}.yml"
      puts flat_hash(YAML::load(IO.read(primary_file))[primary_locale_name])
      File.exists?(primary_file) ? flat_hash(YAML::load(IO.read(primary_file))[primary_locale_name]) : {}
    end

    def flat_hash(data, prefix = '', result = {})
      data.each do |key, value|
        current_prefix = prefix.present? ? "#{prefix}.#{key}" : key

        if !value.is_a?(Hash) || Tolk::Locale.pluralization_data?(value)
          result[current_prefix] = value.respond_to?(:stringify_keys) ? value.stringify_keys : value
        else
          flat_hash(value, current_prefix, result)
        end
      end
      result.stringify_keys
    end

    def filter_out_i18n_keys(flat_hash)
      flat_hash.reject { |key, value| key.starts_with? "i18n" }
    end

    def sync_phrases(translations)
      primary_locale = Tolk::Locale.primary_locale

      # Handle deleted phrases
      translations.present? ? phrases.where(["tolk_phrases.key NOT IN (?)", translations.keys]).destroy_all : phrases.destroy_all

      phrases.reload

      translations.each do |key, value|
        # Create phrase and primary translation if missing
        existing_phrase = phrases.detect {|p| p.key == key} || Tolk::Phrase.create!(:key => key, :application_id => id)
        translation = existing_phrase.translations.primary || primary_locale.translations.build(:phrase_id => existing_phrase.id, :application_id => id)
        translation.text = value

        if translation.changed? && !translation.new_record?
          # Set the primary updated flag if the primary translation has changed and it is not a new record.
          secondary_locales.each do |locale|
            if existing_translation = existing_phrase.translations.detect {|t| t.locale_id == locale.id }
              existing_translation.force_set_primary_update = true
              existing_translation.save!
            end
          end
        end

        translation.primary = true
        translation.save!
      end
    end

    def i18n_hash
      { primary_locale_name => en_translations.each_with_object({}) do |translation, locale|
        if translation.phrase.key.include?(".")
          locale.deep_merge!(unsquish(translation.phrase.key, translation.value))
        else
          locale[translation.phrase.key] = translation.value
        end
      end }
    end

    def unsquish(string, value)
      if string.is_a?(String)
        unsquish(string.split("."), value)
      elsif string.size == 1
        { string.first => value }
      else
        key  = string[0]
        rest = string[1..-1]
        { key => unsquish(rest, value) }
      end
    end
  end
end

