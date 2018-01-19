require 'snmp4em'
require 'google_chart'

class CmtsController < ApplicationController
  include ApplicationHelper
#  before_action :set_cmt, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate

  def initialize
    @report = []
    $sweep_cache = nil

    cacti = "0.0.0.0"

    graph_link = "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=_graph_id_&rra_id=1"

    @ds_util_graph_map = {'cmts1.mm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6519&rra_id=0&view_type=tree",
                          'cmts2.mm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6522&rra_id=0&view_type=tree",
                          'cmts3.mm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6525&rra_id=0&view_type=tree",
                          'cmts4.mm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6527&rra_id=0&view_type=tree",
                          'cmts5.mm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6528&rra_id=0&view_type=tree",
													'cmts1.tbm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6517&rra_id=0&view_type=tree",
													'cmts2.tbm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6524&rra_id=0&view_type=tree",
                          'cmts3.tbm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6526&rra_id=0&view_type=tree",
                          'cmts4.tbm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6865&rra_id=0&view_type=tree",
                          'cmts1.sqpk' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6520&rra_id=0&view_type=tree",
                          'cmts2.sqpk' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6523&rra_id=0&view_type=tree",
                          'cmts3.sqpk' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6905&rra_id=1&view_type",
													'cmts1.twm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6521&rra_id=0&view_type=tree",
                          'cmts1.bwm' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6518&rra_id=0&view_type=tree"}

    @ds_bandwidth_graph_map = {'cmts1.mm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=5472&rra_id=1&view_type=",
                               'cmts2.mm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=5480&rra_id=1&view_type=",
                               'cmts3.mm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=5487&rra_id=1&view_type=",
                               'cmts4.mm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6735&rra_id=1&view_type=",
                               'cmts5.mm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6606&rra_id=1&view_type=",
                               'cmts1.tbm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=5463&rra_id=1&view_type=",
                               'cmts2.tbm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=5462&rra_id=1&view_type=",
                               'cmts3.tbm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6800&rra_id=1&view_type=",
		                           'cmts4.tbm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6855&rra_id=1&view_type=",
                               'cmts1.sqpk' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=5495&rra_id=1&view_type=",
                               'cmts2.sqpk' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6801&rra_id=1&view_type=",
															 'cmts3.sqpk' => "http://#{cacti}/cacti/graph_image.php?local_graph_id=6898&rra_id=0&view_type=tree",
                               'cmts1.twm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6793&rra_id=1&view_type=",
                               'cmts1.bwm' => "http://#{cacti}/cacti/graph.php?action=zoom&local_graph_id=6379&rra_id=1&view_type="
                              }

    # Provisioned CPE History
    cpe_graphids = {'cmts1.bwm' => 6378,
                    'cmts1.mm' => 5471, 'cmts2.mm' => 5479, 'cmts3.mm' => 5502, 'cmts4.mm' => 6200, 'cmts5.mm' => 6312, 'cmts6.mm' => 1131, 'cmts7.mm' => 1143, 'cmts8.mm' => 1155,
                    'cmts1.tbm' => 5470, 'cmts2.tbm' => 5506, 'cmts3.tbm' => 6290, 'cmts4.tbm' => 6864,
                    'cmts1.sqpk' => 5494, 'cmts2.sqpk' => 6185, 'cmts3.sqpk' => 6897,
                    'cmts1.twm' => 6263
                    }

    @cpe_graph_map = {}
    cpe_graphids.each do |k,v|
      @cpe_graph_map[k] = graph_link.gsub(/_graph_id_/,v.to_s)
    end

    # MER History
    mer_graphids = {'cmts1.bwm' => 6377,
                    'cmts1.mm' => 5511, 'cmts2.mm' => 5513, 'cmts3.mm' => 5515, 'cmts4.mm' => 6199, 'cmts5.mm' => 6311,
                    'cmts1.tbm' => 5512, 'cmts2.tbm' => 5514, 'cmts3.tbm' => 6289, 'cmts4.tbm' => 6863,
                    'cmts1.sqpk' => 5510, 'cmts2.sqpk' => 6184, 'cmts3.sqpk' => 6896,
                    'cmts1.twm' => 6279}
    @mer_graph_map = {}
    mer_graphids.each do |k,v|
      @mer_graph_map[k] = graph_link.gsub(/_graph_id_/,v.to_s)
    end
  end

  # GET /cmts
  # GET /cmts.json
  def index
    @cmts = ArrisHeadend.all # Cmt.all
    render :layout => "application"
  end

  # GET /cmts/1
  # GET /cmts/1.json
  def show
    @cmt = ArrisHeadend.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cmt }
    end
  end

  def managec3
    @c3Config = Cmt.getC3Config(params)
    respond_to do |format|
      format.html { render :managec3, :layout => "application" }
    end
  end

  #
  # Sweep modems for stats
  #
	def sweep
    # Call sweep method
		@sweep_data, @ds, @us = Cmt.sweep(params)

    if (!@sweep_data)
      respond_to do |format|
        format.html { render :sweep_failed, :layout => "application" }
      end
    else
      GoogleChart::PieChart.new('340x220', "",false) do |pc|
        pc.data "16+", @ds['16plus'].round(0)
        pc.data "-15 to +15", @ds['-15to+15'].round(0)
        pc.data "-14 or less", @ds['-14less'].round(0)
        @ds_chart = pc.to_url
      end

      GoogleChart::PieChart.new('340x220', "",false) do |pc|
        pc.data "51 to 61", @us['51to61'].round(0)
        pc.data "34 to 51", @us['51to35'].round(0)
        pc.data "34 or less", @us['34less'].round(0)
        @us_chart = pc.to_url
      end

      # Set host and channel headers
  		@sweep_host = params[:target].upcase!
      @sweep_channel = "All Channels" if !params[:channel]
      @sweep_channel = "Channel #{params[:channel].to_i + 1}" if params[:channel]

      ModemSweepCache.new.update(@sweep_data)

      respond_to do |format|
          format.html { render :sweep, :layout => "application" }
      end
    end
	end

  def report
    @cmts = ArrisHeadend.order(name: :asc)

    # Debug
    # ld("Retrieving CMTS list")
    # ld(@cmts)
    # ld(sprintf("%-30s %-30s", "Got C3 list..",Time.now))
    # ld("Got C3 list.. #{Time.now}")
    # ld("Quering C3 Stats.. #{Time.now}")
    # ld(sprintf("%-30s %-30s", "Quering C3 Stats..",Time.now))
    # @cmts.each do |cmts|
    getCMTSChannelCounts()
    # ld("Got C3 Stats.. #{Time.now}")
    # ld(sprintf("%-30s %-30s", "Got C3 Stats..",Time.now))
    # end

    sitemap = {'bwm' => 'Bill Williams', 'mm' => 'Mingus Mt.', 'tbm' => 'Table Mt.', 'sqpk' => 'Squaw Peak', 'twm' => 'Towers Mt.'}
    allsites = 0
    @report.each do |cmts|
      @totals = {} if !@totals

      re = /\w*\d+\.(.*)/
      m = cmts[:host].match re
      site = m[1]
      @totals[sitemap[site]] = 0 if !@totals[sitemap[site]]
      @totals[sitemap[site]] += cmts[:totalsubs]
      allsites += cmts[:totalsubs]
    end
    @totals.merge!({'All Sites' => allsites})
    # ld("Rendering C3 Stats HTML.. #{Time.now}")
    # ld(sprintf("%-30s %-30s", "Rendering C3 Stats HTML..",Time.now))
    # ld(@report)
    respond_to do |format|
        format.html { render :report, :layout => "application" }
    end
  end

  def getCMTSChannelCounts(cmts = nil)

    community = 'broadbandcactus'

    us_interface_state = '1.3.6.1.2.1.2.2.1.8'

    us_registered_sms  = '1.3.6.1.4.1.4115.1.4.3.1.1.1.1.6'
    us_snr             = '1.3.6.1.4.1.4115.1.4.3.6.1.3.1.21'
    us_freq            = '1.3.6.1.2.1.10.127.1.1.2.1.2'
    ch_width           = '1.3.6.1.2.1.10.127.1.1.2.1.3'
    mer                = '1.3.6.1.2.1.10.127.1.1.4.1.5'
    us_channel_type    = '1.3.6.1.2.1.10.127.1.1.2.1.15'
    us_modulation_prof = '1.3.6.1.2.1.10.127.1.1.2.1.4'
		us_util						 = '1.3.6.1.2.1.10.127.1.3.9.1.3'

		ds_util	           = SNMP::ObjectId.new('1.3.6.1.2.1.10.127.1.3.9.1.3.4.128.1')
    ds_modulation      = SNMP::ObjectId.new('1.3.6.1.2.1.10.127.1.1.1.1.4.4')

    ch1_int_state = SNMP::ObjectId.new("#{us_interface_state}.5")
    ch2_int_state = SNMP::ObjectId.new("#{us_interface_state}.6")
    ch3_int_state = SNMP::ObjectId.new("#{us_interface_state}.7")
    ch4_int_state = SNMP::ObjectId.new("#{us_interface_state}.8")
    ch5_int_state = SNMP::ObjectId.new("#{us_interface_state}.9")
    ch6_int_state = SNMP::ObjectId.new("#{us_interface_state}.10")

    ch1_sub_int_state = SNMP::ObjectId.new("#{us_interface_state}.11")
    ch2_sub_int_state = SNMP::ObjectId.new("#{us_interface_state}.12")
    ch3_sub_int_state = SNMP::ObjectId.new("#{us_interface_state}.13")
    ch4_sub_int_state = SNMP::ObjectId.new("#{us_interface_state}.14")
    ch5_sub_int_state = SNMP::ObjectId.new("#{us_interface_state}.15")
    ch6_sub_int_state = SNMP::ObjectId.new("#{us_interface_state}.16")

    ch1 = SNMP::ObjectId.new("#{us_registered_sms}.11")
    ch2 = SNMP::ObjectId.new("#{us_registered_sms}.12")
    ch3 = SNMP::ObjectId.new("#{us_registered_sms}.13")
    ch4 = SNMP::ObjectId.new("#{us_registered_sms}.14")
    ch5 = SNMP::ObjectId.new("#{us_registered_sms}.15")
    ch6 = SNMP::ObjectId.new("#{us_registered_sms}.16")

    ch1_freq = SNMP::ObjectId.new("#{us_freq}.11")
    ch2_freq = SNMP::ObjectId.new("#{us_freq}.12")
    ch3_freq = SNMP::ObjectId.new("#{us_freq}.13")
    ch4_freq = SNMP::ObjectId.new("#{us_freq}.14")
    ch5_freq = SNMP::ObjectId.new("#{us_freq}.15")
    ch6_freq = SNMP::ObjectId.new("#{us_freq}.16")

    ch1_us_snr = SNMP::ObjectId.new("#{us_snr}.11")
    ch2_us_snr = SNMP::ObjectId.new("#{us_snr}.12")
    ch3_us_snr = SNMP::ObjectId.new("#{us_snr}.13")
    ch4_us_snr = SNMP::ObjectId.new("#{us_snr}.14")
    ch5_us_snr = SNMP::ObjectId.new("#{us_snr}.15")
    ch6_us_snr = SNMP::ObjectId.new("#{us_snr}.16")

    ch1_width = SNMP::ObjectId.new("#{ch_width}.11")
    ch2_width = SNMP::ObjectId.new("#{ch_width}.12")
    ch3_width = SNMP::ObjectId.new("#{ch_width}.13")
    ch4_width = SNMP::ObjectId.new("#{ch_width}.14")
    ch5_width = SNMP::ObjectId.new("#{ch_width}.15")
    ch6_width = SNMP::ObjectId.new("#{ch_width}.16")

    ch1_channel_type = SNMP::ObjectId.new("#{us_channel_type}.11")
    ch2_channel_type = SNMP::ObjectId.new("#{us_channel_type}.12")
    ch3_channel_type = SNMP::ObjectId.new("#{us_channel_type}.13")
    ch4_channel_type = SNMP::ObjectId.new("#{us_channel_type}.14")
    ch5_channel_type = SNMP::ObjectId.new("#{us_channel_type}.15")
    ch6_channel_type = SNMP::ObjectId.new("#{us_channel_type}.16")

    ch1_modulation_prof = SNMP::ObjectId.new("#{us_modulation_prof}.11")
    ch2_modulation_prof = SNMP::ObjectId.new("#{us_modulation_prof}.12")
    ch3_modulation_prof = SNMP::ObjectId.new("#{us_modulation_prof}.13")
    ch4_modulation_prof = SNMP::ObjectId.new("#{us_modulation_prof}.14")
    ch5_modulation_prof = SNMP::ObjectId.new("#{us_modulation_prof}.15")
    ch6_modulation_prof = SNMP::ObjectId.new("#{us_modulation_prof}.16")

    ch1_mer = SNMP::ObjectId.new("#{mer}.11")
    ch2_mer = SNMP::ObjectId.new("#{mer}.12")
    ch3_mer = SNMP::ObjectId.new("#{mer}.13")
    ch4_mer = SNMP::ObjectId.new("#{mer}.14")
    ch5_mer = SNMP::ObjectId.new("#{mer}.15")
    ch6_mer = SNMP::ObjectId.new("#{mer}.16")

		ch1_util = SNMP::ObjectId.new("#{us_util}.5.129.1")
    ch2_util = SNMP::ObjectId.new("#{us_util}.6.129.2")
    ch3_util = SNMP::ObjectId.new("#{us_util}.7.129.3")
    ch4_util = SNMP::ObjectId.new("#{us_util}.8.129.4")
    ch5_util = SNMP::ObjectId.new("#{us_util}.9.129.5")
    ch6_util = SNMP::ObjectId.new("#{us_util}.10.129.6")


#    EM.run {
#      @cmts.each do |c3|
#        cmts_data = Array.new()
#        # ld(c3)
#        # Open session with CMTS
#        snmp = SNMP4EM::Manager.new(:version => :SNMPv2c, :host => c3.host, :community => community)
#        # ld(snmp)
#        # snmp = SNMP4EM::SNMPv2.new(:Host => cmts.host, :Community => community)

#        cmts = snmp.get([ch1, ch2, ch3, ch4, ch5, ch6,
#                         ch1_freq, ch2_freq, ch3_freq, ch4_freq, ch5_freq, ch6_freq,
#                         ch1_us_snr, ch2_us_snr, ch3_us_snr, ch4_us_snr, ch5_us_snr, ch6_us_snr,
#                         ch1_width, ch2_width, ch3_width, ch4_width, ch5_width, ch6_width,
#                         ch1_mer, ch2_mer, ch3_mer, ch4_mer, ch5_mer, ch6_mer])

         # If response Callback, process
#        cmts.callback do |response|
#          response.each do |varbind|
#            cmts_data.push(varbind[1].to_s)
#          end

#          channels = cmts_data.each_slice(6).to_a
#          # ld('-'*50)
#          result = processStats(channels,c3)
#          @report.push(result)
#          sleep 0.09
#          EM.stop
#        end
#        snmp = nil
#      end
#    }

    @cmts.each do |c3|

      ld("Performing retrieval of data from #{c3}")
      ld(c3)
      ld('-'*100)

      ping = `fping #{c3.host}`
      ld(ping)
      if (ping !~ /alive/)
        ld("Failed to get ping response from #{c3.host}")
        next
      end

      ld('-'*100)
      ld("Calling snmp to query #{c3.host}")
			ld("SNMP Community: #{community}")
       cmts_data = Array.new()
       SNMP::Manager.open(:Host => c3.host, :Version => :SNMPv2c, :Community => community) do |manager|
         response = manager.get([ch1, ch2, ch3, ch4, ch5, ch6,
                                 ch1_freq, ch2_freq, ch3_freq, ch4_freq, ch5_freq, ch6_freq,
                                 ch1_us_snr, ch2_us_snr, ch3_us_snr, ch4_us_snr, ch5_us_snr, ch6_us_snr,
                                 ch1_width, ch2_width, ch3_width, ch4_width, ch5_width, ch6_width,
                                 ch1_mer, ch2_mer, ch3_mer, ch4_mer, ch5_mer, ch6_mer,
                                 ch1_util, ch2_util, ch3_util, ch4_util, ch5_util, ch6_util,
                                 ch1_channel_type, ch2_channel_type, ch3_channel_type, ch4_channel_type, ch5_channel_type, ch6_channel_type,
                                 ch1_modulation_prof, ch2_modulation_prof, ch3_modulation_prof, ch4_modulation_prof, ch5_modulation_prof, ch6_modulation_prof,
                                 ch1_int_state, ch2_int_state, ch3_int_state, ch4_int_state, ch5_int_state, ch6_int_state,
                                 ch1_sub_int_state, ch2_sub_int_state, ch3_sub_int_state, ch4_sub_int_state, ch5_sub_int_state, ch6_sub_int_state,
                                 ds_modulation, ds_util])

           response.each_varbind do |varbind|
               cmts_data.push(varbind.value.to_s)
           end
       end

       channels = cmts_data.each_slice(6).to_a
ld(channels)
       result = processStats(channels,c3)
       # ld(channels)
       # ld(report)
       @report.push(result)
			end
  end

  def processStats(data, cmts)

		# modems = Plat.get_modemlist_by_sector_channel(cmts.host,1)

    interface_state = { 1 => 'up', 2 => 'down', 2 => 'Admin Down', 4 => 'unknown', 5 => 'dormant', 6 => 'notPresent', 7 => 'lowerLayerDown' }

    ds_modulation_table = { 1 => 'unknown', 2 => 'other', 3 => '64qam', 4 => '256qam', 5 => '512qam', 6 => '1024qam', 7 => 'qpsk', 8 => '16qam'}
    us_modulation_table = { 1 => 'qpsk', 16 => '16qam', 100 => 'qpsk'}

    ds_modulation  = ''
    ds_utilization = 0

    sector_stats = {1 => {:subs => 0, :snr => 0, :freq => 0, :ch_width => 0, :mer => 0, :ch_type => '', :ch_modulation => '', :util =>0, :int_state => 0, :sub_int_state => 0},
                    2 => {:subs => 0, :snr => 0, :freq => 0, :ch_width => 0, :mer => 0, :ch_type => '', :ch_modulation => '', :util =>0, :int_state => 0, :sub_int_state => 0},
                    3 => {:subs => 0, :snr => 0, :freq => 0, :ch_width => 0, :mer => 0, :ch_type => '', :ch_modulation => '', :util =>0, :int_state => 0, :sub_int_state => 0},
                    4 => {:subs => 0, :snr => 0, :freq => 0, :ch_width => 0, :mer => 0, :ch_type => '', :ch_modulation => '', :util =>0, :int_state => 0, :sub_int_state => 0},
                    5 => {:subs => 0, :snr => 0, :freq => 0, :ch_width => 0, :mer => 0, :ch_type => '', :ch_modulation => '', :util =>0, :int_state => 0, :sub_int_state => 0},
                    6 => {:subs => 0, :snr => 0, :freq => 0, :ch_width => 0, :mer => 0, :ch_type => '', :ch_modulation => '', :util =>0, :int_state => 0, :sub_int_state => 0}}

    idx = 0
    data.each do |d|
      idx += 1
      case idx
        # Subscriber Count
        when 1
          (1..6).each do |ch|
            # cpe_prov = Plat.get_arris_SC_count(cmts.host, ch)
            cpe_prov = ArrisProv.get_prov_cpes(cmts.host, ch)
ld("Provisioned CPES...")
ld(cpe_prov)
            sector_stats[ch][:subs] = d[ch-1].to_i
            sector_stats[ch][:prov] = cpe_prov
          end
        # Freq
        when 2
          (1..6).each do |ch|
            sector_stats[ch][:freq] = (d[ch-1].to_f/1000000)
          end
        # SNR
        when 3
          (1..6).each do |ch|
            sector_stats[ch][:snr] = (d[ch-1].to_f/10)
          end
        # Channel Width
        when 4
          (1..6).each do |ch|
            sector_stats[ch][:ch_width] = (d[ch-1].to_f/1000).to_i
          end
        # MER
        when 5
          (1..6).each do |ch|
            sector_stats[ch][:mer] = (d[ch-1].to_f/10)
          end
        # Channel Utilization
        when 6
          (1..6).each do |ch|
            sector_stats[ch][:util] = (d[ch-1])
          end
        # Channel Type
        when 7
          (1..6).each do |ch|
            sector_stats[ch][:ch_type] = d[ch-1]
          end
        # Channel Modulation
        when 8
          (1..6).each do |ch|
            sector_stats[ch][:ch_modulation] = us_modulation_table[d[ch-1].to_i].blank? ? 'UNKNOWN' : us_modulation_table[d[ch-1].to_i].upcase
          end
        when 9
          (1..6).each do |ch|
						if !sector_stats[ch][:int_state].nil?
            sector_stats[ch][:int_state] = interface_state[d[ch-1].to_i].upcase
						end
          end
        when 10
          (1..6).each do |ch|
            sector_stats[ch][:sub_int_state] = d[ch-1].to_i
          end
        when 11
          ds_modulation  = ds_modulation_table[d[0].to_i]
          ds_utilization = d[1].to_i
      end
    end

    totalsubs = 0
    sector_stats.each do |k,v|
      totalsubs += v[:subs]
    end

    avg_us = 0
    ctr = 0
		a = []
    sector_stats.each do |k,v|
			next if v[:snr].to_i == 0
			ctr += 1
      a.push(v[:snr])
    end
    avg_us = (a.reduce(:+).to_f / a.size).round(2)

    sector_stats.merge!({:host => cmts.host, :totalsubs => totalsubs, :title => cmts.name, :ds_freq => cmts.downstream_freq, :polarity => cmts.polarity, :ds_modulation => ds_modulation, :ds_util => ds_utilization, :avg_us => avg_us})
    #{:host => cmts.host, :stats => {:totalsubs => totalsubs, :title => cmts.name, :ds_freq => cmts.downstream_freq, :polarity => cmts.polarity, :stats => sector_stats}}
  end

  #
  # Show Cable Modems
  #
  def scm
    c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3',0,true,true)
    @scm = c3.getSCM()
    c3.close()
    @scmc3 = params[:target]
    respond_to do |format|
        format.html { render :scm, :layout => "application" }
    end
  end

  #
  # Show Cable Modems
  #
  def scmsum
    c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
    @scmsum = c3.getSCMSum()
    c3.close()
    respond_to do |format|
        format.html { render :scmsum, :layout => "application" }
    end
  end

  #
  # Show Cable Modem Detail on a single Modem
  #
  def scmdetail
		ld("Retrieving Cable Modem detail...")
#    if (session[:admin])
			ld("Calling C3.new")
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
			ld(c3)
      scmdetail = c3.getSCMDetail(params[:mac])

      header = 'Modem Detail'

      @scmdetail = {:header => header, :detail => scmdetail}

      c3.close()
      # render :layout => "application"
      respond_to do |format|
          format.html { render :scmdetail, :layout => "application" }
#      end
#    else
#      render :file => "#{Rails.root}/public/404.html", :status => 404
#      return
    end
  end

  #
  # Show Cable Modem Detail on a single Modem
  #
  def schdetail
    ld("Retrieving Cable Host detail...")
    ld("Calling C3.new")
    c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
    ld(c3)
    schdetail, cpemac = c3.getSCHDetail(params[:mac])

    header = 'Host Detail'

    @schdetail = {:header => cpemac, :detail => schdetail}

    c3.close()
    respond_to do |format|
      format.html { render :schdetail, :layout => "application" }
    end
  end

  #
  # Show Host MAC Lookup
  #
  def hostmaclookup
    mac = params[:mac]
     _mac = mac.gsub(/\./,'')
    ld(_mac)
    vendor = open("http://www.macvendorlookup.com/api/CxBwITz/#{_mac}").read
    vendor_company = JSON.parse(vendor)[0]["company"]
    @macvendor = vendor_company
    respond_to do |format|
      format.html { render :showmaclookup, :layout => "application" }
    end
  end

  #
  # Show Flapping Modems List
  #
  def showflaplist
#    if (session[:admin])
      @cmts = params[:target]
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
      @flap_list = c3.getFlapList()
      @summary = c3.getFlapListSummary()

			lc = Cmtsflaphistory.find_by_cmts(params[:target]) || "No Clearing Recorded"
			@lastcleared = lc
			if (lc !~ /^No/)
				@lastcleared = lc.lastcleared.strftime("%m-%d-%Y %H:%M:%S")
			end
			ld(@lastcleared)

      c3.close()
      respond_to do |format|
          format.html { render :showflaplist, :layout => "application" }
      end
#    else
#      render :file => "#{Rails.root}/public/404.html", :status => 404
#      return
#    end
  end

  #
  # Show Running Config
  #
  def showrun
    ld(session)
    if (session[:noc])
      @cmts = params[:target]
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
      @config = c3.getRunningConfig()
      c3.close()
      respond_to do |format|
          format.html { render :showrun, :layout => "application" }
      end
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
      return
    end
  end


  #
  # Show Controllers
  #
  def showcontrollers
    if (session[:admin])
      @cmts = params[:target]
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
      @controllers = c3.showControllers()
      c3.close()
      render :layout => "application"
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
      return
    end
  end

  #
  # Show Environment
  #
  def showenvironment
    if (session[:admin])
      @cmts = params[:target]
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
      @environment = c3.getEnvironment()
      c3.close()
      render :layout => "application"
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
      return
    end
  end

  #
  # Delete Offline Modem(s)
  #
  def deleteoffline
    filter = params[:filter] || 'all'
    if (session[:admin])
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
      if (filter == 'all')
        @offlinecleared = c3.clearOffline()
      else
        ld("Deleting modem #{filter} from #{params[:target]}")
        @offlinecleared = c3.resetModem(params[:filter])
        ld(@offlinecleared)
      end
      c3.close()

      # "\nTotal modems = 315,\tActive= 315, offline = 0\r\nTotal deleted = 0\r\ncmts1#"

      @offlinecleared.gsub!(/(clear cable modem offline delete)/,'')
      @offlinecleared.gsub!(/(cmts\d*#.)$/,'')

      @offlinecleared.gsub!(/\n/,"\n")
      @offlinecleared.gsub!(/\t/,"\r")
      a = @offlinecleared.split("\r")
      a.pop
      @offlinecleared = a.join("\r")
      respond_to do |format|
          format.js
      end
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
      return
    end
  end

  #
  # Send SNMP Set Request to Online Modes to Power Cycle
  #
  def resetmodemcounters
    if (session[:admin])
      if (params[:target] == 'all')
        modems = ModemSweepCache::DATA
        modems.each do |cm|
          ld("snmpset -v1 -c private #{cm[3]} 1.3.6.1.2.1.69.1.1.3.0 i 1")
          `snmpset -v1 -c private #{cm[3]} 1.3.6.1.2.1.69.1.1.3.0 i 1`
        end
      else
        ld("snmpset -v1 -c private #{params[:target]} 1.3.6.1.2.1.69.1.1.3.0 i 1")
        `snmpset -v1 -c private #{params[:target]} 1.3.6.1.2.1.69.1.1.3.0 i 1`
      end
      redirect_to report_path
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
      return
    end
  end

  #
  # Clear ALL modems from Flap List
  #
  def clearflaplist
    if (session[:admin])
      ParamCache.new.update(params[:target])
      c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
      c3.clearFlapList()
      c3.close()
      flash[:notice] = "Flap List has been successfully cleared"
      redirect_to showflaplist_path(:target => ParamCache::PARAM)
    else
      render :file => "#{Rails.root}/public/404.html", :status => 404
      return
    end
  end

  #
  # Show basic Platypus Account Info
  #
  def showplatinfo
    @record = Plat.getAccountInfo(params)
    respond_to do |format|
        format.html { render :showplatinfo, :layout => "application" }
    end
  end

  #
  # Show Provisioned Modem Type Audit
  #
  def showModemAudit
    @record = Plat.getAccountInfo(params)
    respond_to do |format|
        format.html { render :showplatinfo, :layout => "application" }
    end
  end


  protected

  # Authenticate users
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
        if (username == "admin" && password == 'kevlarvci....')
          session[:admin] = true
          session[:noc] = true
          return true
        end
        if (username == "tonyd" && password == 'dodger*ball')
          session[:admin] = true
          session[:noc] = true
          return true
        end
        if (username == "p.mcdougal" && password == 'Sp33dC0NNet7411')
          session[:admin] = true
          session[:noc] = true
          return true
        end
        if (username == "randy.knights" && password == 'Octoman3')
          session[:admin] = false
          session[:noc] = false
          return true
        end
        if (username == "brandon" && password == 'g@tstar....')
          session[:admin] = true
          session[:noc] = false
          return true
        end
        if (username == "dan.spellman" && password == 'dan.spellman7411')
          session[:admin] = true
          session[:noc] = true
          return true
        end
        session[:admin] = false
        session[:noc] = false
        return false
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cmt
    @cmt = Cmt.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cmt_params
    params.require(:cmt).permit(:host, :name, :downstream_freq, :polarity)
  end
end

class ModemSweepCache
  DATA = []
  def update( modems )
    DATA.replace modems
  end
end

class ParamCache
  PARAM = ''
  def update( value )
    ld("Param Value: #{value}")
    PARAM.replace value
  end
end
#
#
#
# json =
# {"id":1,"host":"cmts1.mm","name":"Mingus Mt CMTS 1 (West Sec 1) (231Mhz)","downstream_freq":2509.0,"polarity":"Vertical","created_at":"2013-11-13T23:37:42.000Z","updated_at":"2013-11-15T18:53:36.000Z"},
# {"id":2,"host":"cmts2.mm","name":"Mingus Mt CMTS 2 (East Sec 1) (225Mhz)","downstream_freq":2503.0,"polarity":"Vertical","created_at":"2013-11-13T23:59:55.000Z","updated_at":"2013-11-15T18:53:47.000Z"},
# {"id":3,"host":"cmts3.mm","name":"Mingus Mt CMTS 3 (East Sec 2) (309Mhz)","downstream_freq":2587.0,"polarity":"Vertical","created_at":"2013-11-14T21:53:51.000Z","updated_at":"2013-11-15T18:54:00.000Z"},
# {"id":4,"host":"cmts4.mm","name":"Mingus Mt CMTS 4 (East Sec 3) (243Mhz)","downstream_freq":2521.0,"polarity":"Vertical","created_at":"2013-11-14T23:36:31.000Z","updated_at":"2013-11-15T18:54:12.000Z"},
# {"id":5,"host":"cmts5.mm","name":"Mingus Mt CMTS 5 (West Sec 2) (309Mhz)","downstream_freq":309.0,"polarity":"Vertical","created_at":"2014-01-31T23:22:16.000Z","updated_at":"2014-01-31T23:22:16.000Z"},
# {"id":6,"host":"cmts6.mm","name":"Mingus Mt CMTS 6 (East Sec 3) (243Mhz)","downstream_freq":2521.0,"polarity":"Vertical","created_at":"2013-11-14T23:36:31.000Z","updated_at":"2013-11-15T18:54:12.000Z"},
# {"id":7,"host":"cmts7.mm","name":"Mingus Mt CMTS 7 (East Sec 3) (243Mhz)","downstream_freq":2521.0,"polarity":"Vertical","created_at":"2013-11-14T23:36:31.000Z","updated_at":"2013-11-15T18:54:12.000Z"},
# {"id":8,"host":"cmts8.mm","name":"Mingus Mt CMTS 8 (East Sec 3) (243Mhz)","downstream_freq":2521.0,"polarity":"Vertical","created_at":"2013-11-14T23:36:31.000Z","updated_at":"2013-11-15T18:54:12.000Z"},
# {"id":9,"host":"cmts1.twm","name":"Towers Mt CMTS 1 (345Mhz)","downstream_freq":2623.0,"polarity":"Vertical","created_at":"2013-12-07T16:27:57.000Z","updated_at":"2013-12-10T17:22:57.000Z"},
# {"id":10,"host":"cmts1.tbm","name":"Table Mt CMTS 1 (Sec 1) (225Mhz)","downstream_freq":2503.0,"polarity":"Horizontal","created_at":"2013-11-14T21:54:08.000Z","updated_at":"2013-11-15T18:59:08.000Z"},
# {"id":11,"host":"cmts2.tbm","name":"Table Mt CMTS 2 (Sec 2) (243Mhz)","downstream_freq":2531.0,"polarity":"Horizontal","created_at":"2013-11-14T21:54:26.000Z","updated_at":"2013-11-15T18:59:14.000Z"},
# {"id":12,"host":"cmts3.tbm","name":"Table Mt CMTS 3 (Sec 3) (249Mhz)","downstream_freq":2587.0,"polarity":"Vertical","created_at":"2014-01-04T06:12:00.000Z","updated_at":"2014-01-04T06:12:00.000Z"},
# {"id":13,"host":"cmts4.tbm","name":"Table Mt CMTS 4 (Sec 4) (2550.0Mhz)","downstream_freq":2550.0,"polarity":"Vertical","created_at":"2015-12-10T15:23:59.000Z","updated_at":"2015-12-10T15:23:59.000Z"},
# {"id":14,"host":"cmts1.bwm","name":"Bill Williams CMTS 1 (West Sec 1) (221Mhz)","downstream_freq":221.0,"polarity":"Vertical","created_at":"2014-03-12T19:50:51.000Z","updated_at":"2014-03-12T19:50:51.000Z"},
# {"id":15,"host":"cmts1.sqpk","name":"Squaw Peak CMTS 1 (Sec 1 u0026 3) (303Mhz)","downstream_freq":2581.0,"polarity":"Vertical","created_at":"2013-11-14T21:54:44.000Z","updated_at":"2013-11-15T18:59:21.000Z"},
# {"id":16,"host":"cmts2.sqpk","name":"Squaw Peak CMTS 2 (Sec 4) (231Mhz)","downstream_freq":2509.0,"polarity":"Vertical","created_at":"2013-11-14T21:54:59.000Z","updated_at":"2013-11-15T18:59:25.000Z"},
# {"id":17,"host":"cmts3.sqpk","name":"Squaw Peak CMTS 3 (Sec ?) (?Mhz)","downstream_freq":2587.0,"polarity":"Vertical","created_at":"2016-04-11T22:32:09.000Z","updated_at":"2016-04-11T22:32:09.000Z"},
# {"id":18,"host":"cmts4.sqpk","name":"Squaw Peak CMTS 4 (Sec 6) (309Mhz)","downstream_freq":2587.0,"polarity":"Vertical","created_at":"2016-04-27T07:01:03.000Z","updated_at":"2016-04-27T07:01:03.000Z"}
#
# json.each do |headend|
#   ArrisHeadend.create(headend)
# end
