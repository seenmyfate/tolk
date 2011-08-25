module Tolk
  class LocalesController < Tolk::ApplicationController
    before_filter :find_application
    before_filter :find_locale, :only => [:show, :all, :updated, :update]
    before_filter :ensure_no_primary_locale, :only => [:all, :update, :show, :updated]

    def index
      @locales = @application.secondary_locales
    end
  
    def show
      respond_to do |format|
        format.html do
          @phrases = @locale.phrases_without_translation(@application,params[:page])
        end
        format.atom { @phrases = @locale.phrases_without_translation(@application,params[:page], :per_page => 50) }
        format.yaml { render :text => @locale.to_hash.ya2yaml(:syck_compatible => true) }
      end
    end

    def update
      @locale.translations_attributes = params[:translations]
      @locale.save
      if @locale.errors.any?
        flash[:notice] = @locale.errors[:"translations.text"].join(',')
      end
      redirect_to request.referrer
    end

    def all
      @phrases = @locale.phrases_with_translation(params[:page])
    end

    def updated
      @phrases = @locale.phrases_with_updated_translation(params[:page])
      render :all
    end

    def create
      Tolk::Locale.create!(params[:tolk_locale])
      redirect_to tolk_application_locales_path(@application, @locale)
    end

    private

    def find_locale
      @locale = @application.locales.find_by_name!(params[:id])
    end

    def find_application
      @application = Tolk::Application.find(params[:application_id])
    end
  end
end
