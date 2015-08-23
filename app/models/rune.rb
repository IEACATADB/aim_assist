class Rune < ActiveRecord::Base
    def stats
    self.attributes.delete_if{|k,v| v.nil? || k=="id"||k=="r_type"}.to_s
    
    end
end
