class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table (:users, :id => false) do |t|
      t.string :id, null: false, index: {unique: true}, :auto_increment => false, :options => 'PRIMARY KEY'
      t.string :role, null: false
      t.string :name 
      t.string :email, null: false, index: {unique: true}
      t.text :passwd
      t.text :salt
      t.string :status
      t.datetime :last_login
      t.timestamps 

    end

    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end
