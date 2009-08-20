# SexyTempPasswords Module
module SexyTempPasswords #:nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def sexy_temp_password
      path = File.join($sexy_plugin_path, 'sexy-passwords.txt')
      puts path
      passwords = File.open(path).read.split(/\n/)
      random = passwords[rand(passwords.size - 1)]
      digits = ''
      4.times { |i| digits << (rand(9)+1).to_s }
      return "#{random}#{digits}"
    end
  end
    
end
