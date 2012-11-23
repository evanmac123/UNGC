# SexyPermalinks
module SexyPermalinks
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
    def receiver.permalink(symbol)
      class_eval do
        cattr_reader :permalink_using
        alias_method_chain :to_param, :permalink
      end
      @@permalink_using = symbol
    end
  end

  module ClassMethods
    def find_by_permalink(string)
      find_by_id string.to_i
    end
  end
  
  module InstanceMethods
    def permalink
      @permalink ||= self.send self.class.permalink_using
    end
    
    def to_param_with_permalink
      if permalink.blank?
        to_param_without_permalink
      else
        escaped = CGI.escape(permalink.downcase)
        link = escaped.gsub(/(\%..|\+)/, '-')
        link.gsub!(/-+/, '-')
        link.gsub!(/-\Z/, '')
        "#{id}-#{link}"
      end
    end
  end
end