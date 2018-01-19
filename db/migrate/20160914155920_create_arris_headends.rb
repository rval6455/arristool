class CreateArrisHeadends < ActiveRecord::Migration
  def change
    create_table :arris_headends do |t|
      t.string :host
      t.string :name
      t.float :downstream_freq
      t.string :polarity

      t.timestamps
    end
  end
end
