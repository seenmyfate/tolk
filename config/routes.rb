Rails.application.routes.draw do |map|
  map.namespace('tolk') do |tolk|
    tolk.root :controller => 'applications'
    tolk.resources :applications, :has_many => :locales
    tolk.resources :locales
    tolk.all_locales '/applications/:application_id/locales/:id/all', :controller=>"locales", :action=>"all"
    tolk.updated_locales '/applications/:application_id/locales/:id/updated', :controller=>"locales", :action=>"updated"
    tolk.search '/applications/:application_id/search', :controller=>"searches", :action=>"show"
  end
end
