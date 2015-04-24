class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
    	t.string :code
    	t.integer :fire_severity
    	t.integer :police_severity
    	t.integer :medical_severity
    	t.time :resolved_at
        t.boolean :full_response, default: false

    	t.timestamps null: false
    end

    add_index :emergencies, :code, unique: true
  end
end
