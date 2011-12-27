require "kue/version"

module Kue
  module Store
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :set_table_name, :kue_settings
      base.send :set_primary_key, :key
    end
  
    module ClassMethods         
      def keys
        KueStore.all.map(&:key).map(&:to_sym)
      end
  
      def [](key)
        entry = KueStore.find_by_key(key)
        entry ? YAML.load(entry.value) : nil
      end
       
      def []=(key, value)
        setting = KueStore.find_or_create_by_key(key)
        setting.value = value.to_yaml
        setting.save!
      end
  
      def delete!(key)
        KueStore.delete_all(:key => key)
      end
  
      def exists?(key)
        self[key].present?
      end
      
      def clear!
        KueStore.destroy_all
      end
    end
  end
end

class KueStore < ActiveRecord::Base
  include Kue::Store
end
