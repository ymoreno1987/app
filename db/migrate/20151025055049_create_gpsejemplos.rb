class CreateGpsejemplos < ActiveRecord::Migration
  def change
    create_table :gpsejemplos do |t|
      t.float :latitude
      t.float :longitude
      t.string :timestamp
      t.integer :idUsuario

      t.timestamps
    end
  end
end
