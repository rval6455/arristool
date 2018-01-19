# require 'net/telnet'
require 'open-uri'
require 'json'

# Extend Array Class to include Sum and Average methods
class Array
    def sum
      inject(0.0) { |result, el| result + el }
    end

    def mean(precision = 10)
      mean = sum / size

      if (precision)
        return sprintf("%3.#{precision}f", mean)
      end
      return mean
    end

    def drop_last
      self[0...-1]
    end
end

#
#
#
class Cmt < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  #
  # Sweep CMTS Modems procedure
  #
  def self.sweep(params)
    host    = params[:target]
    channel = params[:channel] || nil

    iplist = []

    # Get a cable modem list from CMTS which will provide us the ability
    # to filter "online" CMs as well as Receive Level at Head End, DOCSIS version
    # and Modulation.
    c3 = C3.new(params[:target],'kevlarvci....','h0ck3ysc0r3')
    scm = c3.getSCM(channel)
    c3.close()

    # Iterate of SCM result and push IP's onto a array stack to write to temp file to pass to
    # Event Driven sweep routine outside of this Rails App
    nothing_to_sweep = true
    scm.each do |r|
      if ((r[:state] !~ /(init|offline)/i) && (r[:ip] != '0.0.0.0'))
        iplist.push(r[:ip])
        nothing_to_sweep = false
      end
    end

    return false,'No modems registered on this channel!',false if nothing_to_sweep

    snmpcommunity = 'public' if !['cmts4.mm'].include?(host)
    snmpcommunity = 'c@ctu5br0adb@nd' if ['cmts1.bwm','cmts2.tbm','cmts3.tbm','cmts3.mm','cmts4.mm','cmts5.mm','cmts2.sqpk'].include?(host)

  sweep = Sweep.new(iplist, snmpcommunity,5,2)
  result = sweep.perform()
  #ld(result)

    cms = []
    result.each do |r|
      r.each do |k,v|
        cmts = scm.select{ |key,value| key[:ip] == k}
        v[:ip] = k
        v[:state] = cmts[0][:state]
        v[:rcv_pwr] = cmts[0][:rcv_pwr]
        v[:cmts_snr] = cmts[0][:snr]
        v[:us_mod] = cmts[0][:us_mod]
        v[:docsis] = cmts[0][:docsis]
        cms.push(v)
      end
    end

    report = []

    # Interate of sweep result array, locate matching online SCM record for
    # Modulation, DOCSIS v, SNR, etc as seen from CMTS
    cms.each do |cm|

      # Get address info for Google Maps link
      # addrinfo = Plat.getAddress({:ip => cm[:ip]})
      addrinfo = false
      a = []
      if (!addrinfo)
        a = ['Not found','Not found', '#']
      else
        addr1 = addrinfo.addr1.gsub(/\s*$/,'')
        addr2 = addrinfo.addr2.gsub(/\s*$/,'')
        city  = addrinfo.city.gsub(/\s*$/,'')
        state = addrinfo.state.gsub(/\s*$/,'')
        zip   = addrinfo.zip.gsub(/\s*$/,'')

        addr = "#{addr1}\+#{city}\+#{state}\+#{zip}"

        url = "https://www.google.com/maps/?q=#{addr}\&fid=7"
        a.push(addrinfo.name,addrinfo.d_custid,url)
      end

      cm[:customer] = a[0]
      cm[:cid]      = a[1]
      cm[:url]      = a[2]

      # Now push CPE stats onto Report Array
      report.push(cm)

      report
    end

    ds_values = getDSUSOnly(cms,'down'.to_sym)
    us_values = getDSUSOnly(cms,'up'.to_sym)
#ld(ds_values)
    snr_values = getDSUSOnly(cms,'cpe_snr'.to_sym)
#ld(snr_values)
#ld('*'*50)
    ds = calcDSUSStats(ds_values)
#ld(ds)
    us = calcDSUSStats(us_values)

    ds_cat = categorizeDS(ds_values)
    us_cat = categorizeUS(us_values)

    ds.merge!(ds_cat)
    us.merge!(us_cat)

    return report, ds, us
  end

  #
  # Extract element for DS/US values and return simple array of DS or US values
  # to calc min, avg, max
  #
  def self.getDSUSOnly(data,key)
    values = []
    data.each do |m|
      next if m[key].to_i == 0
      values.push(m[key].to_f)
    end
    return values
  end

  #
  # Return Min,Avg,Max values for DS/US
  #
  def self.calcDSUSStats(data)
    avg = data.mean(2)
    min = data.min
    max = data.max
    return {:min => min, :avg => avg, :max => max}
  end

  #
  # Categorize the Upstream Values
  #
  def self.categorizeUS(data)
      levels = {'51to61' => 0.0, '51to35' => 0.0, '34less' => 0.0, :us_cat_total => data.length}

      # Categorize Upstream
      data.each do |v|
        # v = v.to_i
        if v >= 51
          levels['51to61'] += 1.0
        elsif v >= 34.001 && v <= 51
          levels['51to35'] += 1.0
        elsif v <= 34
          levels['34less'] += 1.0
        end
      end
      return levels
  end

  #
  # Categorize Downstream Values
  #
  def self.categorizeDS(data)
      levels = {'16plus' => 0.0, '-15to+15' => 0.0, '-14less' => 0.0, :ds_cat_total => data.length}

      # Categorize Downstream Values
      data.each do |v|
        # v = v.to_i
        if v >= 15
          levels['16plus'] += 1.0
        elsif v >= -15 && v < 16
          levels['-15to+15'] += 1.0
        elsif v < -15
          levels['-14less'] += 1.0
        end
      end
      return levels
  end

  def self.getURL(mac)
    # addrinfo = Plat.getAddress({:mac => mac})
    addr = 'Not found'
    # if (!addrinfo)
    #   addr = 'Not found'
    # else
    #   addr1 = addrinfo.addr1.gsub(/\s*$/,'')
    #   addr2 = addrinfo.addr2.gsub(/\s*$/,'')
    #   city  = addrinfo.city.gsub(/\s*$/,'')
    #   state = addrinfo.state.gsub(/\s*$/,'')
    #   zip   = addrinfo.zip.gsub(/\s*$/,'')
    #   addr = "#{addr1}\+#{city}\+#{state}\+#{zip}"
    # end
    url = "https://www.google.com/maps/?q=#{addr}\&fid=7"
  end

  #
  # Get IP List of Registered Modems from CMTS
  #
  def self.getC3RegisteredCMIPList(host)
    # oid = '1.3.6.1.2.1.4.22.1.3.36'
    oid = '1.3.6.1.2.1.10.127.1.3.3.1.3'

    community = 'broadbandcactus'

    cmlist = SNMP::ObjectId.new(oid)

    cm_data = Array.new()
    SNMP::Manager.open(:Host => host, :Version => :SNMPv2c, :Community => community) do |manager|
      manager.walk(cmlist) do |row|
        row.each { |vb| cm_data.push(vb.value.to_s) if vb.value.to_s =~ /(^10)/ }
      end
    end
    return cm_data
  end
end
