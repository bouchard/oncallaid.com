class ActiveRecord::Base
  def all_columns(klass)
    self.class.all_columns(klass)
  end

  def self.all_columns(klass)
    klass = klass.kind_of?(self) ? klass : klass.to_s.classify.constantize
    klass.column_names.map{ |c| "#{klass.to_s.tableize}.#{c}" }.join(', ')
  end
end