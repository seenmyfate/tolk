# I know, worst naming ever...
module Tolk
  class ApplicationsController < Tolk::ApplicationController
    def index
      @applications = Tolk::Application.all
    end

    def create
      @application = Tolk::Application.create!(params[:tolk_application])
      redirect_to :action => :index
    end
  end
end
