module AdminTreeStructure::ArchivePage
  def tree_children
    tree_children = []
    last = edge_date(false)
    if last
      first = edge_date(true)
      current = first
      while(current <= last)
        tree_children.unshift ArchiveYearTreePage.new(self, current, last)
        current = current.next_year.beginning_of_year
      end
    end
    tree_children + children.find(:all, :conditions => ['virtual = ?', true])
  end 
  
  def edge_date(first)
    if !first && children.find(:first, :conditions => 'updated_at is null')
      return Time.now
    end
    order = first ? 'asc' : 'desc'
    child = children.find(:first, :order => "published_at #{order}", :conditions => 'not(published_at is null)')
    edge = child.published_at if child
    child = children.find(:first, :order => "updated_at #{order}", :conditions => 'published_at is null and not(updated_at is null)')
    if child
      if first
        edge = child.updated_at if !edge || child.updated_at < edge
      else
        edge = child.updated_at if !edge || child.updated_at > edge
      end
    end
    edge
  end
  
  def tree_child(slug)
    first = [edge_date(true),Time.utc(slug.to_i)].max
    last = edge_date(false)
    ArchiveYearTreePage.new(self, first, last)
  end
  
  # def tree_child(required_role)
  #   'all'
  # end

  class ArchiveTreePage
    def virtual?
      true
    end
    def self.display_name
      'Page'
    end
    def parent
      @parent
    end
    def required_role
      'all'
    end
  end
  
  class ArchiveYearTreePage < ArchiveTreePage
    def initialize(parent, start_time, end_time=nil)
      @parent = parent
      @start_time = start_time
      @end_time = end_time
    end
    
    def id
      @start_time.strftime("#{@parent.id}_%Y")
    end
    
    def title
      @start_time.strftime("%Y")
    end
    
    def tree_children
      start_month = @start_time.month
      end_month = 12
      end_month = @end_time.month if @end_time && @end_time.year <= @start_time.year
      (@start_time.month..end_month).map do |m|
        tree_child(m)
      end.reverse
    end
    
    def tree_child(slug)
      ArchiveMonthTreePage.new(@parent, @start_time.beginning_of_year.months_since(slug.to_i - 1))
    end
    
    def url
      "#{@parent.url}#{title}"
    end
    
    def status
      Status.new(:name => '')
    end
    
    def required_role
      'all'
    end
  
  end
  
  class ArchiveMonthTreePage < ArchiveTreePage
    def initialize(parent, start_time)
      @parent = parent
      @start_time = start_time
    end
    def id
      @start_time.strftime("#{@parent.id}_%Y_%m")
    end
    def title
      @start_time.strftime("%B")
    end
    def tree_children
      end_time = @start_time.next_month.beginning_of_month
      condition_string = 'virtual = ? and (published_at >= ? and published_at < ? or (published_at is null and ('
      condition_string += 'updated_at is null or ' if Time.now.utc.beginning_of_month == @start_time.beginning_of_month
      condition_string += '(updated_at >= ? and updated_at < ?))))'
      @parent.children.find(:all, 
        :conditions => [
          condition_string, 
          false,
          @start_time, 
          end_time,
          @start_time, 
          end_time,
          ],
        :order => 'published_at desc, updated_at desc'
      )
    end
    def url
      "#{@parent.url}#{title}"
    end
    def status
      Status.new(:name => '')
    end
    def required_role
      'all'
    end
  end
end
