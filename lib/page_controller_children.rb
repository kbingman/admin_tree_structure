module PageControllerChildren
  def self.included(clazz)
    clazz.class_eval do
      def children
        id, *tree_children = params[:id].split('_')
        @parent = tree_children.inject(Page.find(id)) {|current, slug| current.tree_child(slug) }
         @level = params[:level].to_i
         response.headers['Content-Type'] = 'text/html;charset=utf-8'
         render(:layout => false)
      end
      before_filter :include_admin_tree_javascript, :only => :index
      private
        def include_admin_tree_javascript
          @content_for_page_scripts ||= ''
          @content_for_page_scripts <<(<<-EOF)
	    Object.extend(SiteMap.prototype, {
	      extractPageId: function(row) {
	        if (/page-([\\d]+(_[\\d_A-Z]+)?)/i.test(row.id)) {
	          return RegExp.$1;
		}
	      }
	    });
	  EOF
        end
    end
  end
end
