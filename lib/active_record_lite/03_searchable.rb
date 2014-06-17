require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable 
  def where(params)
    # ...
    wheres = params.keys.map { |param| "#{param} = ?"}.join(' AND ')
    
    
    query = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE #{wheres}
    SQL
    
    parse_all(DBConnection.execute(query, params.values))
    #results.map { |result| self.new(result)}
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
