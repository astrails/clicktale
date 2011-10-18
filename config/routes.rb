ActionController::Routing::Routes.draw do |map|
  map.connect 'clicktale/:filename.:format', :controller => "clicktale", :action => "show"
end

