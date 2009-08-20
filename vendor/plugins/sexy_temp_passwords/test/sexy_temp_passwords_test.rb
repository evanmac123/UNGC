require 'test/unit'
require 'rubygems'
gem 'activerecord', '>= 2.0.1'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.column :login, :string
      t.column :created_at, :datetime      
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class User < ActiveRecord::Base
  include SexyTempPasswords
  def self.table_name()
    'users'
  end
end

class SexyTempPasswordsTest < Test::Unit::TestCase

  def setup
    setup_db
    @user = User.create!(:login => 'lebowski')
  end

  def teardown
    teardown_db
  end
  
  def test_sexy_temp_password
    assert User.respond_to?('sexy_temp_password')
    random_pass = User.sexy_temp_password
    length = random_pass.size
    word_part, num_part = random_pass[0..(length-5)], random_pass[(length-4), length]
    for i in (0..3)
      j = num_part[i..i].to_i
      assert(1 <= j)
      assert(j <= 9)
    end
    assert(word_array.include?(word_part))
  end
  
  private
  
  def word_array
    path = File.join($sexy_plugin_path, 'sexy-passwords.txt')
    File.open(path).read.split(/\n/)
  end
  
end
