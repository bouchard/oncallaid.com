module Sortable

  def self.included(base)
    base.class_eval do

      after_save :clean_sort_order
      before_create :initialize_sort_order

      def initialize_sort_order
        self.sort_order ||= ((self.class.all.map(&:sort_order).max + 1) rescue 1)
      end

      def clean_sort_order
        if self.class.where(:sort_order => self.sort_order).count > 1
          overlapping_objects = self.class
            .where('sort_order >= ?', self.sort_order)
            .where('id != ?', self.id)
          overlapping_objects.each do |a|
            a.sort_order += 1
            a.save
          end
        end
      end

    end
  end

end