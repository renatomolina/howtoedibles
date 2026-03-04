class CreateEbookSignups < ActiveRecord::Migration[5.2]
  def change
    create_table :ebook_signups do |t|
      t.string :email

      t.timestamps
    end
  end
end
