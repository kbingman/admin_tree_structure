# Uncomment this if you reference any of your controllers in activate
require_dependency 'application_controller'

class AdminTreeStructureExtension < Radiant::Extension
  version "1.0"
  description "Adds structure to the admin tree"
  url "http://soxbox.no-ip.org/"
  
  # breaks_tests 'Admin::PageControllerTest', %w{test_index__with_cookie} if respond_to?(:breaks_tests)
  
  def activate
    Admin::PagesController.send(:include, AdminTreeStructure::PagesControllerExtensions)
    Admin::NodeHelper.send(:include, AdminTreeStructure::NodeHelperExtensions)
    ArchivePage.send(:include, AdminTreeStructure::ArchivePage)
  end
  
  def deactivate
  end
  
end
