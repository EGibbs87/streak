class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.timestamps
      
      t.string :sport
      t.string :description
      t.string :first_option
      t.string :second_option
      t.string :winner
      t.string :heat
      t.string :first_option_chosen
      t.string :second_option_chosen
      t.string :first_final
      t.string :second_final
      t.string :comments_count
    end
  end
end
