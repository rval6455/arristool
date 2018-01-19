class CreateCmtsflaphistories < ActiveRecord::Migration
  def change
    create_table :cmtsflaphistories do |t|
      t.string :cmts
      t.datetime :lastcleared

      t.timestamps
    end
  end
end
