# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class AdminTreeStructureExtension < Radiant::Extension
  version "1.0"
  description "Adds structure to the admin tree"
  url "http://soxbox.no-ip.org/"
  
  breaks_tests 'Admin::PageControllerTest', %w{test_index__with_cookie} if respond_to?(:breaks_tests)
  
  # define_routes do |map|
  #   map.connect 'admin/admin_tree_structure/:action', :controller => 'admin/admin_tree_structure'
  # end
  
  def activate
    Admin::PageController.send(:include, PageControllerChildren)
    Admin::NodeHelper.send(:include, NodeHelperChanges)
    ArchivePage.send(:include, ArchivePageTreeStructure)
    # admin.tabs.add "Admin Tree Structure", "/admin/admin_tree_structure", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Admin Tree Structure"
  end
  
end
