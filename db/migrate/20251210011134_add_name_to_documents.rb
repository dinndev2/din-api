class AddNameToDocuments < ActiveRecord::Migration[7.2]
  def change
    add_column :documents, :name, :string
  end
end
