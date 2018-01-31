class DbConnectionHelper
  def self.backend
    klass = ActiveRecord::Base.connection.class.name
    if klass == 'ActiveRecord::ConnectionAdapters::Mysql2Adapter'
      :mysql
    elsif klass == 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
      :postgres
    end
  end
end