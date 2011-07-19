module Tolk
  class SearchesController < Tolk::ApplicationController
    before_filter :find_locale_and_application
  
    def show
      @phrases = @locale.search_phrases(params[:q], params[:scope].to_sym, params[:page])
    end

    private

    def find_locale_and_application
      @application = Tolk::Application.find(params[:application_id])
      @locale = Tolk::Locale.find_by_name!(params[:locale])
    end
  end
end
