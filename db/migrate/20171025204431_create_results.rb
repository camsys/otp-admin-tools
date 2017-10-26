class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.text :request
      t.text :response
      t.timestamps
    end
  end
end
