class Plat < ActiveRecord::Base
  # attr_accessible :title, :body
  establish_connection :plat
 	# geocoded_by :address

 #  def self.address
	# 	[street, city, state, country].compact.join(', ')
	# end

	def self.initialize()
    @sitemap = {'cmts1.mm' => {:site => 'Mingus Mt West', :sector => 1},
                'cmts2.mm' => {:site => 'Mingus Mt East', :sector => 1},
                'cmts3.mm' => {:site => 'Mingus Mt East', :sector => 2},
                'cmts4.mm' => {:site => 'Mingus Mt East', :sector => 3},
                'cmts1.tbm' => {:site => 'Table Mt', :sector => 1},
                'cmts2.tbm' => {:site => 'Table Mt', :sector => 2},
							  'cmts3.tbm' => {:site => 'Table Mt', :sector => 3},
                'cmts1.sqpk' => {:site => 'Squaw Peak', :sector => 3},
                'cmts2.sqpk' => {:site => 'Squaw Peak', :sector => 4},
                'cmts1.twm' => {:site => 'Towers Mt', :sector => 1},
                'cmts1.bwm' => {:site => 'Bill Williams', :sector => 1}
              }
	end

	def self.getAccountInfo(params)
		_mac = formatMac(params[:mac])
		ip = params[:ip]

		sql = ''
		if (!params[:mac].blank?)
			sql = "SELECT c.name, c.id, vm.d_active, pt.name as type, p.number FROM customer as c, phone as p, phone_type as pt, vyyo_modem as vm WHERE c.id = vm.d_custid and p.idnum = c.id and pt.id = p.type and vm.mac_address = '#{_mac}'"
		else
			sql = "SELECT c.name, c.id, vm.d_active, pt.name as type, p.number FROM customer as c, phone as p, phone_type as pt, vyyo_modem as vm WHERE c.id = vm.d_custid and p.idnum = c.id and pt.id = p.type and vm.cpeIP = '#{ip}'"
		end

    result = self.find_by_sql(sql)
    if (result.blank?)
    	return ''
    end

    name  = result[0]['name']
    cid   = result[0]['id']
    state = result[0]['d_active'].upcase

    address = self.getAddress({:cid => cid})

    numbers = []
    result.each do |number|
    	numbers.push({:type => number['type'], :number => number['number']})
    end

    return result = {:name => name, :cid => cid, :state => state, :numbers => numbers, :address => address}
	end

	def self.get_modemlist_by_sector_channel(cmts,channel)
		self.initialize()
  	self.table_name = 'vyyo_modem'
		self.primary_key = 'data_id'

		modems = where(:d_active => 'Y', :serviceFacility => @sitemap[cmts][:site], :sector => @sitemap[cmts][:sector], :channel => channel)
		modems = select("d_custid, cpeIP")

		ld(modems.length)
		return modems
	end

	def self.get_nnmodem_count()
		self.table_name = 'nn_modem'
		self.primary_key = 'data_id'

	    modems = where(:d_active => 'Y')
	    modems = modems.order(:data_id)
	    modems = modems.select("data_id, value")
	end

	def self.get_arris_SC_count(cmts,channel)
		self.table_name = 'vyyo_modem'
		self.primary_key = 'data_id'

		sitemap = {'cmts1.mm' => {:site => 'Mingus Mt West', :sector => 1},
							 'cmts2.mm' => {:site => 'Mingus Mt East', :sector => 1},
							 'cmts3.mm' => {:site => 'Mingus Mt East', :sector => 2},
							 'cmts4.mm' => {:site => 'Mingus Mt East', :sector => 3},
							 'cmts1.tbm' => {:site => 'Table Mt', :sector => 1},
							 'cmts2.tbm' => {:site => 'Table Mt', :sector => 2},
							 'cmts1.sqpk' => {:site => 'Squaw Peak', :sector => 3},
							 'cmts2.sqpk' => {:site => 'Squaw Peak', :sector => 4},
							 'cmts1.twm' => {:site => 'Towers Mt', :sector => 1},
							 'cmts1.bwm' => {:site => 'Bill Williams', :sector => 1}
							}


		count = where(:d_active => 'Y', :serviceFacility => @sitemap[cmts][:site], :sector => @sitemap[cmts][:sector], :channel => channel)
		count = count.select("data_id") || 0
		count.length
	end

	def self.getCoords(ip)
	    self.table_name = 'vyyo_modem'
	    self.primary_key = 'data_id'

	    result = find_by_sql("SELECT vm.d_custid, c.name, a.addr1, a.addr2, a.city, a.state, a.zip FROM vyyo_modem as vm, customer as c, address as a WHERE c.id = vm.d_custid and a.idnum = vm.d_custid and a.type = 2 and vm.cpeIP = '#{ip}'")

	    if (result.blank?)
	    	return false
	    else
	    	return result[0]
	    end
	end

	def self.getAddress(params)

			sql = "SELECT vm.d_custid, c.name, a.addr1, a.addr2, a.city, a.state, a.zip FROM vyyo_modem as vm, customer as c, address as a WHERE c.id = vm.d_custid and a.idnum = vm.d_custid and a.type = 2 and "

			if (!params[:ip].blank?)
				sql = sql + "vm.cpeIP = '#{params[:ip]}'"
			elsif(!params[:cid].blank?)
				sql = sql + "vm.d_custid = #{params[:cid]}"
			else
				_mac = formatMac(params[:mac],2)
				sql = sql + "vm.mac_address = '#{_mac}'"
			end

			result = find_by_sql(sql)

	    if (result.blank?)
	    	return false
	    else
	    	return result[0]
	    end
	end
end
