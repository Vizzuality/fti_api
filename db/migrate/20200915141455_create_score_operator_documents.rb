class CreateScoreOperatorDocuments < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      dir.up do
        create_table :score_operator_documents do |t|
          t.date :date, null: false
          t.boolean :active, null: false, default: true
          t.float :all
          t.float :country
          t.float :fmu

          t.index :date
          t.index :active
          t.references :operator,foreign_key: { on_delete: :cascade }, index: true
          t.timestamps
        end

        # After creating the table, let's copy the data there and remove the former fields
        Operator.unscoped.find_each do |operator|
          ScoreOperatorDocument.create! date: Date.today, active: true, operator_id: operator.id,
                                        all: operator.percentage_valid_documents_all,
                                        country: operator.percentage_valid_documents_country,
                                        fmu: operator.percentage_valid_documents_fmu
        end

        remove_columns :operators, :percentage_valid_documents_all,
                      :percentage_valid_documents_country, :percentage_valid_documents_fmu
      end

      dir.down do
        add_column :operators, :percentage_valid_documents_all, :float
        add_column :operators, :percentage_valid_documents_country, :float
        add_column :operators, :percentage_valid_documents_fmu, :float

        ScoreOperatorDocument.find_each do |sod|
          o = Operator.find sod.operator_id
          o.update!(percentage_valid_documents_all: sod.all,
                    percentage_valid_documents_fmu: sod.fmu,
                    percentage_valid_documents_country: sod.country)
        end

        drop_table :score_operator_documents
      end
    end
  end
end
