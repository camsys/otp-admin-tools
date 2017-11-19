module AdminHelpers
  
  def get_admin_pages
    urls = Rails.application.routes.url_helpers
    
    @admin_pages = [
      { label: "Configuration",       url: urls.admin_configs_path,           show: true},
      { label: "Groups",       url: urls.admin_groups_path,            show: true},
      { label: "Users",        url: urls.admin_users_path,            show: true}
    ].select {|page| page[:show] }
    .sort_by { |page| page[:label] }
  end
  
end