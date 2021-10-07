class Dog
    attr_accessor :name, :breed, :id

    def initialize(attr_hash)
        @name = attr_hash[:name]
        @breed = attr_hash[:breed]
        @id = attr_hash[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL 
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end 

    def save 
        sql = <<-SQL 
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, @name, @breed)
        @id = DB[:conn].execute("SELECT * FROM dogs").last[0]
        self
    end 

    def self.create(attr_hash)
        Dog.new(attr_hash).save
    end 

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end 

    def self.all
        DB[:conn].execute("SELECT * FROM dogs").collect do |row|
            self.new_from_db(row)
        end
    end 

    def self.find_by_name(name)
       row =  DB[:conn].execute("SELECT * FROM dogs WHERE (name = ?)", name)[0]
       Dog.new_from_db(row)
    end 

    def self.find(id)
        row =  DB[:conn].execute("SELECT * FROM dogs WHERE (id = ?)", id)[0]
        Dog.new_from_db(row)
    end 

    def self.find_or_create_by(attr_hash)
        name = attr_hash[:name]
        breed = attr_hash[:breed]

        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        row =  DB[:conn].execute(sql, name, breed)[0]
        # binding.pry
        if row
            return self.new_from_db(row)
        else 
            return Dog.create(attr_hash)
        end 
    end


    def update 

       sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"

       DB[:conn].execute(sql, @name, @breed, @id)
    end 



end
