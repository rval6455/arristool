class ArrisProv < ActiveRecord::Base
  # attr_accessible :title, :body
	establish_connection :arris_prov
	self.table_name = 'modems'
	self.primary_key = 'mid'

	def self.get_prov_cpes(cmts,channel)
		return 0
		sitemap = {'cmts1.mm' => {:site => 'mmw', :sector => 1},
							 'cmts2.mm' => {:site => 'mme', :sector => 1},
							 'cmts3.mm' => {:site => 'mme', :sector => 2},
							 'cmts4.mm' => {:site => 'mme', :sector => 3},
							 'cmts5.mm' => {:site => 'mmw', :sector => 2},
							 'cmts6.mm' => {:site => 'mme', :sector => 4},
							 'cmts7.mm' => {:site => 'mme', :sector => 5},
							 'cmts8.mm' => {:site => 'mme', :sector => 6},
							 'cmts1.tbm' => {:site => 'tbm', :sector => 1},
							 'cmts2.tbm' => {:site => 'tbm', :sector => 2},
							 'cmts3.tbm' => {:site => 'tbm', :sector => 3},
               'cmts4.tbm' => {:site => 'tbm', :sector => 4},
							 'cmts1.sqpk' => {:site => 'sqpk', :sector => 3},
							 'cmts2.sqpk' => {:site => 'sqpk', :sector => 4},
							 'cmts3.sqpk' => {:site => 'sqpk', :sector => 5},
							 'cmts4.sqpk' => {:site => 'sqpk', :sector => 6},
							 'cmts1.bwm' => {:site => 'bwm', :sector => 1},
							 'cmts1.twm' => {:site => 'twm', :sector => 1}
							}

		cfgfile = ''
		cfgfile1 = ''
		cfgfile2 = ''
		cfgfile3 = ''
		cfgfile4 = ''
		if (cmts == 'cmts1.sqpk' && channel.to_i != 5)
			cfgfile1 = "#{sitemap[cmts][:site]}-s1-ch#{channel}%"
			cfgfile2 = "#{sitemap[cmts][:site]}-s2-ch#{channel}%"
			cfgfile3 = "#{sitemap[cmts][:site]}-s3-ch#{channel}-256%"
		elsif (cmts == 'cmts1.sqpk' && channel.to_i == 5)
			cfgfile1 = "#{sitemap[cmts][:site]}-in-s1-ch#{channel}-256%"
			ld('hello')
			ld(cfgfile1)
		else
			cfgfile = "#{sitemap[cmts][:site]}-s#{sitemap[cmts][:sector]}-ch#{channel}%"
		end
		# ld("select count(mid) from modems where state IN ('CURRENT','CHANGED') and cfgfile like #{cfgfile}")
		if (cmts == 'cmts1.sqpk')
			count = where("state IN ('CURRENT') and (cfgfile like ? or cfgfile like ? or cfgfile like ?)", cfgfile1, cfgfile2, cfgfile3)
		else
			count = where("state IN ('CURRENT') and cfgfile like ?", cfgfile)
		end
		count = count.select("mid") || 0
		count.length
	end

end
