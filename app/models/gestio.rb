class Gestio < ActiveRecord::Base
  # attr_accessible :title, :body
	establish_connection :gestio
	self.table_name = 'host'
	self.primary_key = 'id'

	def self.getWiMaxAPList()
		aps = where("hostname like ? and host_descr like ?", 'ap1%', 'WIMAX%')
		aps = aps.select('hostname')
	end
end
