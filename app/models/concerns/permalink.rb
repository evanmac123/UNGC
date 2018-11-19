module Permalink
  extend ActiveSupport::Concern

  def self.included(base)
    cattr_reader :permalink_using

    base.extend ClassMethods
  end

  module ClassMethods
    attr_accessor :permalink_using

    def permalink(symbol)
      self.permalink_using = symbol
    end
  end

  def permalink
    @permalink ||= self.send(self.class.permalink_using)
  end

  def to_param
    return super if permalink.blank?

    escaped = CGI.escape(permalink.downcase)
    link = escaped.gsub(/(\%..|\+)/, '-')
    link.gsub!(/-+/, '-')
    link.gsub!(/-\Z/, '')
    "#{id}-#{link}"
  end
end
