module NodeHelperChanges
  def self.included(clazz)
    clazz.class_eval do
      def expanded_rows
        unless @expanded_rows
	  @expanded_rows = case
          when row_string = cookies[:expanded_rows]
            row_string.split(',').select { |x| /^\d+(_[\d_a-z]+)?$/i === x }.compact
          else
            []
          end

	  if homepage and !@expanded_rows.include?(homepage.id.to_s)
	    @expanded_rows << homepage.id.to_s
	  end
	end
	@expanded_rows
      end
      def expanded
        show_all? || expanded_rows.include?(@current_node.id.to_s)
      end      
      def children_class
        unless children.empty?
          if expanded
            " children-visible"
          else
            " children-hidden"
          end
        else
          " no-children"
        end
      end
      
      def expander
        unless children.empty?
          image((expanded ? "collapse" : "expand"), 
                :class => "expander", :alt => 'toggle children', 
                :title => '')
        else
          ""
        end
      end      
      
      def children
        if @current_node.respond_to? :tree_children
          @current_node.tree_children
        else
          @current_node.children
        end
      end
    end
  end
end
