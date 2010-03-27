module AdminTreeStructure::PagesControllerExtensions
  def self.included(base)
    base.class_eval do
      
      before_filter :include_admin_tree_javascript, :only => :index
      
      def new
        self.model = Page.new_with_defaults(config)
        self.model.parent = Page.find(params[:page_id])
        if params[:page_id].blank?
          self.model.slug = '/'
        end
        response_for :singular
      end
      
      protected
      
        def load_models
          # This a bit ugly, but is needed as the tree_children are just an array
          # It would be better to make the tree_chilren a class...
          self.models = model_class.to_a
        end
      
        def model_name
          # Needed because of above
          'Page'
        end
        
        def load_model
          # Needed because of above
          self.model = if params[:id]
            Page.find(params[:id])
          else
            Page.new
          end
        end
      
      private

        def model_class
          if params[:page_id]
            id, *tree_children = params[:page_id].split('_')
            parent = tree_children.inject(Page.find(id)) {|current, slug| current.tree_child(slug) }
            parent.respond_to?(:tree_children) ? parent.tree_children : parent.children
          else
            Page
          end
        end
      
        def include_admin_tree_javascript
          include_javascript 'admin/admin_tree/sitemap.js'
        end
    end
  end
end
