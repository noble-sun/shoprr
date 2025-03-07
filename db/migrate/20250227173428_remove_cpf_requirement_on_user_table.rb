class RemoveCpfRequirementOnUserTable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :cpf, true
  end
end
