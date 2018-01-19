module CmtsHelper

  # Extend Array Class
  class Array
    def sum
      inject(0.0) { |result, el| result + el }
    end

    def mean 
      sum / size
    end
  end

  #
  # Avg upstream utilization
  # Receives: Complex hash of CMTS stats
  # Returns : Returns float
  #
  def avg_us_util(cmts)
    a = []
    cmts.each do |k,v|
      next if k == :int_state && v != 'UP'
      next if ![1,2,3,4,5].include?(k)
      v.each do |kk,vv|
        next if kk != :util
        a.push(vv.to_f)
      end
    end
    r = a.inject(0.0) { |sum, el| sum + el } / a.size
  end

  #
  # Help determine length of Flap List display to avoid displaying
  # Footer breadcrumb if nothing displaying or a short list
  #
  # Receives: Hash
  # Returns : true/false
  #
  def extendedFlapList(list)

    length = 0
    if (list.class == {}.class)
      list.each do |k,v|
        length += 1
        if (v.class == [].class)
          length += v.length
        end
      end
    end
    return true if length > 20
    return false    
  end

  # -------------------------------------------------------------------------------
  #
  # Formatted Data Usage Calulator for View
  #
  # - Can return results formated with string (bits,Bytes,MB,TB, etc.)
  # -------------------------------------------------------------------------------
  def formatBytes(bytes)
  	return 0 if (bytes.nil? || bytes.to_i == 0)

    bytes = bytes.to_f

    data_used = Hash.new()

    data_used[:B] = 0
    data_used[:kb] = 0
    data_used[:mb] = 0
    data_used[:gb] = 0
    data_used[:tb] = 0

    data_used[:b]  = bytes.to_i * 10
    data_used[:B]  = bytes
    data_used[:kb] = data_used[:B].to_f / 1000
    data_used[:mb] = data_used[:kb].to_f / 1000
    data_used[:gb] = data_used[:mb].to_f / 1000
    data_used[:tb] = data_used[:gb].to_f / 1000

    if (data_used[:tb] > 1)
    	return "#{data_used[:tb].round(2)}TB"
    elsif (data_used[:gb] > 1)
    	return "#{data_used[:gb].round(2)}GB"
    elsif (data_used[:mb] > 1)
    	return "#{data_used[:mb].round(2)}MB"
    elsif (data_used[:kb] > 1)
    	return "#{data_used[:kb].round(2)}KB"
    elsif (data_used[:B] > 1)
    	return "#{data_used[:B].round(2)}"
    elsif (data_used[:b] > 1)
    	return "#{data_used[:b].round(2)}bits"
    end
  end

  #
  # Check mac prefix against list of known DOCSIS v2 modems on CommSpeed's system
  #
  # Receives: MAC address
  # Returns : true/false
  #
  def sanctionedModem(mac)
    # ld("method: sanctionedModem(#{mac})")

    _mac = formatMac(mac,2,":")

    validMac = ['00:0e:9b','00:19:7d','00:19:7e','00:14:a4','00:16:ce','00:16:cf','00:1f:e1','00:1f:e2','00:22:69','78:e4:00','c0:cb:38','f0:7b:cb','00:1e:4c','00:1f:3a','00:1d:d9', '90:6e:bb']
    return true if validMac.include?(_mac[0,8])
    return false
  end

  #
  # Format zipcode
  #
  # Receives: String
  # Returns : String (formated)
  #
  def formatZipCode(zip,delimiter="-")
    re = /([0-9]{5})/

    # Remove all delimiters
    zip.gsub!(/[\,\.\-:\s]*/,'')

    parts = zip.to_s.split(re)
    parts.delete_if {|x| x == ''}
    parts.join("#{delimiter}")
  end
end
