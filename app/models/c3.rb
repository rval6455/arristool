class C3
  include ApplicationHelper
  def initialize(h,passwd,passwd_en,cable_int_base=0,debug=false,log=false)

    channel_base_index = cable_int_base

    @host = h
    @cable_int_base = cable_int_base

    telnetdebug = debug ? true : false
    telnetlog = log ? true : false
    telnetlogfile = '/tmp/telnet.log'

    telnet_arguments={ "Binmode"    => false,        # default: false
                       "Host"       => "#{@host}",  # default: "localhost"
                       "Port"       => 23,           # default: 23
                       "Prompt"     => /[$%#>]\z/n, # default: /[$%#>] \z/n
                       "Telnetmode" => false,         # default: true
                       "Timeout"    => 10,           # default: 10
                       "Waittime"   => 0}            # default: 0

    telnet_arguments['Dump_log'] = "/tmp/telnetDebug.log" if telnetdebug
    telnet_arguments['Output_log'] = telnetlogfile if telnetlog

    @terminal_length_issued = false
    @base = Net::Telnet::new(telnet_arguments)

    @base.waitfor(/[:\s]\z/n)
    @base.puts('admin')
    @base.waitfor(/[:\s]\z/n)
    @base.puts(passwd)
    @base.waitfor(/[\>]\z/n)
    @base.puts('en')
    @base.waitfor(/[:\s]\z/n)
    @base.puts(passwd_en)
    @base.waitfor(/[#]\z/n)
    @base.puts('terminal length 0')
    @base.waitfor(/[#]\z/n)
    @base.puts('terminal width 90')
    @base.waitfor(/[#]\z/n)

    @validType = {'tdma' => true, 'atdma' => true}
    @channel_map = {1 => 0, 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5}
  end

  #
  # Query C3/CMTS for a show cable modem list
  #
  # Params: ch - Channel filter to sweep.  Defaults to nil and will sweep all channels
  #
  def getSCM(ch=nil)
    result = ''

    cmd = 'scm columns int snr rec-pwr cpe ip mac up-mod reg-type uptime status'
    if (!ch.nil?)
      cmd = cmd + " | i C1/1/U#{ch}.0"
    end

    @base.cmd(cmd) { |c| result += c }

    # Move result into array
    results = result.split("\r\n")

    # Remove any ending space char
    results.map! {|x| x.gsub(/\s+$/,'')}

    # Remove column headers and footer
    if (ch.nil?)
      # results.shift
      # results.shift
    end
    # results.pop

    scmdetail = []

    re = /(C\d{1}\/\d{1}\/U\d{1}\.\d{1})\s+(\d{1,2}\.\d*)\s+(\-?\d+\.\d)\s+(\d*\/\d*)\s+(\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3})\s+([a-f0-9]{4}\.[a-f0-9]{4}\.[a-f0-9]{4})\s+(\w+)\s+(D\d\.\d+\w?)\s+(\d{1,2}\:\d{1,2}\:\d{1,2})(.*)$/

    sorted_a = []
    results.sort {|x,y| x[0,9] <=> y[0,9] }.each do |line|
      sorted_a.push(line)
    end

    sorted_a.each do |line|
      m = line.match re
      ld(m)
      next if m.nil?
      channel = m[1]
      state   = m[10].gsub(/\s+$/,'')
      snr     = m[2].to_f
      rcv_pwr = m[3].to_f
      cpe     = m[4].gsub(/\s+$/,'')
      ip      = m[5].gsub(/\s+$/,'')
      mac     = m[6].gsub(/\s+$/,'')
      us_mod  = m[7].gsub(/\s+$/,'')
      docsis  = m[8].gsub(/\s+$/,'')
      uptime  = m[9]

      scmdetail.push({:cmts => @host, :ch => channel, :state => state, :snr => snr, :rcv_pwr => rcv_pwr, :cpe => cpe,
              :ip => ip, :mac => mac, :us_mod => us_mod, :docsis => docsis, :uptime => uptime})
    end

    scmdetail
  end

  #
  # Query C3/CMTS for a show cable modem detail on a specific registered cpe
  #
  def getSCMDetail(mac)

    ld("getSCMDetail(): #{mac}")
    _mac = mac.gsub(/\./,'')
    ld(_mac)
    vendor = open("http://www.macvendorlookup.com/api/CxBwITz/#{_mac}").read
    vendor_company = JSON.parse(vendor)[0]["company"]

    ld("Reteiving Vendor information")
    #vendor = open("http://api.macvendors.com/#{_mac}").read
    #vendor_company = vendor
    ld("Vendor: #{vendor_company}")

    result = ["Modem Vendor:#{vendor_company}"]
    ld(result)
    _mac = formatC3Mac(mac)

    result2 = ''

    # Get list
    @base.cmd("show cable modem #{_mac} detail") { |c| result2 += c }

    # Move result into array
    a = result2.split("\n")

    # Remove any ending space char
    a.map! {|x| x.gsub(/\s$/,'')}
    a.delete_if {|x| x == "show cable modem #{_mac} detail" || x.blank?}

    # Remove column footer
    a.pop
    a.pop

    results = result + a

  end

  #
  # Query C3/CMTS for a show cable modem detail on a specific registered cpe
  #
  def getSCHDetail(mac)

    ld("getSHMDetail(): #{mac}")
    _mac = mac.gsub(/\./,'')
    ld(_mac)

    _mac = formatC3Mac(mac)

    result = ''

    # Get list
    @base.cmd("show cable host #{_mac}") { |c| result += c }

    # Move result into array
    a = result.split("\n")

    # Log result
    a.each {|e| ld(e)}

    # Remove any ending space char
    a.delete_if {|x| x == "show cable host #{_mac}" || x.blank?}
    a.delete_if {|x| puts x; x.match(/^(MAC Address)/)}

    # Remove column footer
    a.pop

    # Now format the individual lines
    # c0c1.c083.8e3d  216.19.38.75             learned
    # Array of hashes
    parsed_a = []
    a.each do |e|
      m = e.match /^([a-f0-9\.]+)\s+(\d{2,3}\.\d{0,3}\.\d{0,3}\.\d{0,3})\s+(\w+)/
      if (!m.nil?)
        parsed_a.push({:mac => m[1],:ip => m[2],:type => m[3]})
      end
    end
    return parsed_a, mac
  end

  #
  # Show Cable Modem summary
  #
  # Returns: Array of hashes
  #
  def getSCMSum()

    # Interface  Total Offline Unregistered Rejected Registered
    #
    # "CA1/0/U0.0 32    0       3            0        29"
    # "CA1/0/U1.0 34    0       0            0        34"
    # "CA1/0/U2.0 30    0       2            0        28"
    # "CA1/0/U3.0 31    0       0            0        31"
    # "CA1/0/U4.0 0     0       0            0        0"
    # "CA1/0/U5.0 0     0       0            0        0"
    # "Cable1/0   127   0       5            0        122"

    ld("getSCMSum()")

    result = ''

    # Get list
    @base.cmd("show cable modem sum") { |c| result += c }

    # Move result into array
    a = result.split("\n")

    # Log result
    # a.each {|e| ld(e.gsub!(/\r/,''))}

    4.times do
      a.shift
    end
    a.pop

    result = []
    a.each do |l|
      l.gsub!(/\s+\r/,'')
      re = /^(.{10})\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+$)/
      m = l.match re
      result.push({:int => m[1], :total => m[2], :offline => m[3], :unreg => m[4], :reject => m[5], :registered => m[6]})
    end
    return result
  end

  #
  # Show Flapping Modems
  #
  def getFlapList(ch=nil,getCust=true)

    result = ''

    cmd = ''
    cmd = 'show cable flap-list sort-flap' if getCust
    cmd = 'show cable flap-list sort-interface' if !getCust

    if (!ch.nil?)
      cmd = cmd + " | i C1/1/U#{ch}.0"
    end

    if (!@terminal_length_issued)
      @base.cmd('terminal length 0') #{ |c| ld(c) }
      @terminal_length_issued = true
    end

    @base.cmd(cmd) { |c| result += c }

    # Move result into array
    result.gsub!(/\r/,'')
    results = result.split(/\n/)
    # ld("[MOVED INTO ARRAY]")
    # ld('-'*100)
    # ld(results)

    # Remove any ending space char
    results.map! {|x| x.gsub(/\s$/,'')}
    results.delete_if {|x| x==''}
    # ld("[REMOVED END SPACE]")
    # ld('-'*100)
    # ld(results)

    # Remove column headers and footer
    results.pop
    # ld('-'*100)
    # ld("[POPPED")
    # ld(results)

    if (ch.nil?)
      results.shift
      results.shift
      results.shift
    end
    # ld("[SHIFTED")
    # ld('-'*100)
    # ld(results)

    # Group flapping mpdems by Cable Interface
    sorted_h = {}
    re = /(C\d{1}\/\d{1}\/U\d{1}\.\d{1})/
    results.each do |l|
      # ld("Matching #{l}")
      m = l.match re
      # ld("MATCH: #{m}")
      sorted_h[m[1]] = [] if sorted_h[m[1]].nil?
      sorted_h[m[1]].push(l)
      # ld(sorted_h)
    end
    # ld('[SORTED INTO HASH]')
    # ld('-'*100)
    # ld(sorted_h)

    flap_list = {}

    # Mac Addr      CableIF   Ins   SM Rsp % CRC       P-Adj Flap   Time
    #001f.3a21.5e40 C1/0/U3.0 0     100.0000 0         6     6      SEP 17 20:23:52
    #0016.ce83.d450 C1/0/U4.0 219    95.2924 4294967291184257184476 SEP 18 14:35:11
    re1 = /([a-f0-9]{4}\.[a-f0-9]{4}\.[a-f0-9]{4})\s+(C\d{1}\/\d{1}\/U\d{1}\.\d{1})\s+(\d*)\s+(\d*\.\d*)\s+([\?\*\!]?\d*)\s+(\d*)\s+(\d*)\s+(\w*\s+\d*\s+\d*:\d*:\d*)$/
    re2 = /([a-f0-9]{4}\.[a-f0-9]{4}\.[a-f0-9]{4})\s+(C\d{1}\/\d{1}\/U\d{1}\.\d{1})\s+(\d*)\s+(\d*\.\d*)\s+([\?\*\!]?\d{1,10})\s?(\d{1,6})\s?(\d{1,6})\s+(\w*\s+\d*\s+\d*:\d*:\d*)$/

    sorted_h.each do |k,v|
      flap_list[k] = [] if flap_list[k].nil?
      v.each do |l|
        # ld("Matching #{l}")
        m = l.match re1
        if (m.nil?)
          m = l.match re2
        end
        mac      = m[1].nil? ? 'N/A' : m[1]
        channel  = m[2]
        ins      = m[3]
        sm_response = m[4]
        crc      = m[5]
        p_adj    = m[6]
        flap     = m[7]
        time     = m[8]

        url = ''
        url = Cmt.getURL(mac) if getCust

        flap_list[k].push({:cmts => @host, :mac => mac, :ch => channel, :ins => ins, :sm_response => sm_response, :crc => crc, :p_adj => p_adj, :flap => flap, :time => time, :url => url})
      end
    end

    return flap_list
  end

  #
  # Show Flapping Modems
  #
  def getFlapListSummary()

    result = ''

    cmd = 'show cable flap-list summary'

    @base.cmd(cmd) { |c| result += c }

    # Move result into array
    result.gsub!(/\r/,'')
    results = result.split(/\n/)

    # Remove any ending space char
    results.map! {|x| x.gsub(/\s+$/,'')}
    results.delete_if {|x| x==''}

    # Remove column headers and footer
    results.pop
    results.shift
    results.shift
    results.shift

    flap_list_summary = []

    # Mac Addr       CableIF   Ins   SM Rsp % CRC       P-Adj Flap   Time
    re = /(C\d{1}\/\d{1}\/U\d{1}\.\d{1})\s+(\d*)\s+(\d*\.\d*)\s+(\d*)\s+(\d*)\s+(\d*)$/

    results.each do |l|
      m          = l.match re
      channel    = m[1]
      ins        = m[2]
      sm_response= m[3]
      crc        = m[4]
      p_adj      = m[5]
      flap       = m[6]

      flap_list_summary.push({:ch => channel, :ins => ins, :sm_response => sm_response, :crc => crc, :p_adj => p_adj, :flap => flap})
    end

    return flap_list_summary
  end
  #
  # Clear all Flapping Modems from list
  #
  def clearFlapList()
    result = ''
    # Get controller states
    @base.cmd("clear cable flap-list all") { |c| result += c }
    result.gsub!(/.*#/,'')

    w = Cmtsflaphistory.find_by_cmts(@host) || Cmtsflaphistory.new()
    w.cmts = @host
    w.lastcleared = Time.now().strftime("%Y-%m-%d %H:%M:%S")
    result = w.save
    ld(result)
  end

  #
  # Get Controller States
  #
  def getRunningConfig()
    result = ''
    @base.cmd("show run") { |c| result += c }
    result.gsub!(/.*#/,'')
  end

  #
  # Get Controller States
  #
  def showControllers()
    result = ''
    # Get controller states
    @base.cmd("show controllers") { |c| result += c }
    result.gsub!(/.*#/,'')
  end

  #
  #
  #
  def getEnvironment()
    result = ''
    # Get controller states
    @base.cmd("show environment") { |c| result += c }
    t = result.split(/\n/)
    t.map! do |r|
      if r[/degrees/]
        m = r.match(/(\d+\.\d+)\sdegrees$/)[1]
        temp = celcius2farenheight(m)
        "#{r} #{temp}"
      end
      "#{r} (#{temp})"
    end
    # t.map! {|x| c2f(x)}
    result = t.join("\n")
    result.gsub!(/.*#/,'')
  end

def c2f(c)
  c.gsub!(/(\d{1,3}\.\d{1}\sdegrees)/,'99')
end

  #
  # Close telnet session
  #
  def close()
    @base.close
  end

  #
  # Force a modem to start Ranging and re-Register
  #
  def resetModem(mac)
    _mac = self.formatC3Mac(mac)
    result = ''
    @base.cmd("clear cable modem #{_mac} delete") { |c| result += c }
    result
  end

  #
  # Clear all "offline" modems
  #
  def clearOffline()
    result = ''
    @base.cmd("clear cable modem offline delete") { |c| result += c }
    result
  end

  #
  # Turn down a specific channel
  #
  def turnDownChannel(ch)
    result = ''
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    @base.cmd("cable upstream #{ch} shutdown") { |c| result += c }
    @base.cmd("cable upstream #{ch}.0 shutdown") { |c| result += c }
    @base.cmd("end") { |c| result += c }
    result
  end

  #
  # Turn up a specific channel
  #
  def turnUpChannel(ch)
    result = ''
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    @base.cmd("no cable upstream #{ch} shutdown") { |c| result += c }
    @base.cmd("no cable upstream #{ch}.0 shutdown") { |c| result += c }
    @base.cmd("end") { |c| result += c }
    result
  end

  #
  # Turn down ALL channels
  #
  def turnDownAllChannels()
    result = ''
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    (0..5).each do |ch|
      @base.cmd("cable upstream #{ch} shutdown") { |c| result += c }
      @base.cmd("cable upstream #{ch}.0 shutdown") { |c| result += c }
    end
    @base.cmd("end") { |c| result += c }
    result
  end

  #
  # Turn up ALL channels
  #
  def turnUpAllChannels()
    result = ''
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    (0..5).each do |ch|
      @base.cmd("no cable upstream #{ch} shutdown") { |c| result += c }
      @base.cmd("no cable upstream #{ch}.0 shutdown") { |c| result += c }
    end
    @base.cmd("end") { |c| result += c }
    result
  end

  #
  # Change Upstream Channel Frequency
  #
  def setUpstreamChannelFrequency(ch,freq)
    result = self.turnDownChannel(ch)
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    @base.cmd("cable upstream #{ch} frequency #{freq}") { |c| result += c }
    @base.cmd("cable upstream #{ch} fixed-receive #{freq}") { |c| result += c }
    @base.cmd("end") { |c| result += c }
    result += self.turnUpChannel(ch)
    result
  end

  #
  # Set Upstream Channel Width
  #
  def setUpstreamChannelWidth(ch,width)

    return "Invalid channel index!" if !validChannel(ch)

    validWidth = [200000, 400000, 800000, 1600000, 3200000, 6400000]
    return "Invalid channel width!" if !validWidth.include?(width)

    result = self.turnDownChannel(ch)
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    @base.cmd("cable upstream #{ch} channel-width #{width}") { |c| result += c }
    @base.cmd("end") { |c| result += c }
    result += self.turnUpChannel(ch)
    result
  end

  #
  # Change channel type (DOCSIS 1, 2)
  #
  def setUpstreamChannelType(ch,channelType)
    validType = {'tdma' => true, 'atdma' => true}
    return "Invalid channel type!" if !validType[channelType]

    result = self.turnDownChannel(ch)
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    @base.cmd("cable upstream #{ch}.0 channel-type #{channelType}") { |c| result += c }
    @base.cmd("end") { |c| result += c }
    result += self.turnUpChannel(ch)
    result
  end

  #
  # Change modulation profile to one pre-defined in C3
  #
  def setUpstreamChannelModulationProfile(ch,profile)
    result = self.turnDownChannel(ch)
    @base.cmd("conf t") { |c| result += c }
    @base.cmd("int ca1/0") { |c| result += c }
    @base.cmd("cable upstream #{ch}.0 modulation-profile #{profile}") { |c| result += c }
    @base.cmd("end") { |c| result += c }
    result += self.turnUpChannel(ch)
    result
  end

  # ******************************************
  # Utility Methods
  #

  #
  # Validate Channel Index
  #
  def validChannel(ch)
    return false if ![0,1,2,3,4,5].include?(ch)
    return true
  end

  #
  # Format a MAC Address to 4.4.4
  #
  def formatC3Mac(mac)
    if mac.nil?
      return
    end

    # Remove all delimiters
    mac.gsub!(/[\.\-:\s]*/,'')

    # Insert ':' back into Mac Addr
    re = /([0-9a-fA-F]{4})/
    mac_a = mac.split(re)
    mac_a.delete_if {|x| x == ''}
    mac = mac_a.join('.')
  end

  def celcius2farenheight(temp)
    calc1 = temp.to_f * 2
    calc2 = calc1 - 4
    "#{calc2 + 32} F"
  end
end
