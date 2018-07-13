class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :name
      t.boolean :done, null: false
      t.boolean :passed, null: false

      t.timestamps
    end
  end
end
