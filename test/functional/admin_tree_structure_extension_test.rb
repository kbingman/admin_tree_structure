require File.dirname(__FILE__) + '/../test_helper'

class AdminTreeStructureExtensionTest < Test::Unit::TestCase
  
  fixtures :users, :pages
  test_helper :pages, :page_parts, :caching, :login
  
  def setup
    @controller = Admin::PageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:existing)
    
    @page_title = 'Just a Test'
    
    destroy_test_page
    destroy_test_part
  end  
  
  def test_initialization
    assert_equal File.join(File.expand_path(RAILS_ROOT), 'vendor', 'extensions', 'admin_tree_structure'), AdminTreeStructureExtension.root
    assert_equal 'Admin Tree Structure', AdminTreeStructureExtension.extension_name
  end

  def test_javascript_included
    get :index
    assert_response :success
    assert_match %r{Object\.extend\(SiteMap\.prototype}, @response.body
  end
  
  def test_index__with_cookie
    write_cookie 'expanded_rows', "1,5,9,10,11,12,52"
    get :index
    assert_response :success
    #children of 12 shouldn't be rendered, as 12 is an ArchivePage
    assert_rendered_nodes_where do |page| 
      [nil, 1, 5, 9, 10, 11, 52].include?(page.parent_id) || (
        page.parent_id == 12 && (
          ArchiveDayIndexPage === page ||
          ArchiveMonthIndexPage === page ||
          ArchiveYearIndexPage === page
        )
      )
    end
  end
  
  def test_index__with_cookie__with_month_nodes
    write_cookie 'expanded_rows', "1,5,9,10,11,12,12_2000,12_2000_06,52"
    get :index
    assert_response :success
    #should have 2000 and 2001 year nodes
    assert_node "12_2000"
    assert_node "12_2001"
    #should have month nodes for 2000, starting at May
    (1..4).each do |i|
      assert_no_node "12_2000_#{sprintf '%02d', i}"
    end
    (5..12).each do |i|
      assert_node "12_2000_#{sprintf '%02d', i}"
    end
    #should have no month nodes for 2001
    (1..12).each do |i|
      assert_no_node "12_2001_#{sprintf '%02d', i}"
    end    
    #children of 12 shouldn't be rendered, as 12 is an ArchivePage
    assert_rendered_nodes_where do |page| 
      [nil, 1, 5, 9, 10, 11, 52].include?(page.parent_id) || (
        page.parent_id == 12 && (
          (Time.local(2000,6)...Time.local(2000,7)).include?(page.published_at) ||
          page.virtual?
        )
      )
    end    
  end
  
  def test_tree_children__display_nil_updated_at_under_today
    year_id = "12_#{Time.now.strftime('%Y')}"
    month_id = "12_#{Time.now.strftime('%Y_%m')}"
    no_updated_at_page = Page.find(53)
    archive_page = Page.find(12)
    children = archive_page.tree_child(Time.now.strftime('%Y')).tree_child(Time.now.strftime('%m')).tree_children
    assert children.include?(no_updated_at_page)
  end

  def test_index__display_nil_updated_at_under_today
    year_id = "12_#{Time.now.strftime('%Y')}"
    month_id = "12_#{Time.now.strftime('%Y_%m')}"
    write_cookie 'expanded_rows', "1,12,#{year_id},#{month_id}"
    get :index
    assert_response :success
    assert_node year_id
    assert_node month_id
    assert_node '53'
  end
  
  protected
  
    def assert_node(id)
      assert_tag :tag => 'tr', :attributes => {:id => "page-#{id}" }
    end
    
    def assert_no_node(id)
      assert_no_tag :tag => 'tr', :attributes => {:id => "page-#{id}" }
    end
  
    def assert_rendered_nodes_where(&block)
      wanted, unwanted = Page.find(:all).partition(&block)
      wanted.each do |page|
        assert_node(page.id)
      end
      unwanted.each do |page|
        assert_no_node(page.id)
      end
    end  

    def write_cookie(name, value)
       @request.cookies[name] = CGI::Cookie.new(name, value)
    end
end
