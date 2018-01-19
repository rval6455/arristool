module ApplicationHelper
	# Debug Logging
	def ld(*args)
	    File.open("#{Rails.root}/log/mylog.log", 'a') do |l|
	    	args.each do |arg|
      			l.puts arg.inspect
				end
	    end
	end

	#
	# Format MAC Address to a variety of options
	#
	# - MAC: xx:xx:xx:xx:xx:xx
	# - octs:4, delimiter: . results in xxxx.xxxx.xxxx
	# - octs:6, delimiter: - results in xxxxxx-xxxxxx
	# - octs:3, delimiter: : results in xxx:xxx:xxx:xxx
	#
	def formatMac(mac,octs=2,delimiter=':')
	  if mac.nil?
	    return
	  end

	  # Remove all delimiters
	  mac.gsub!(/[\.\-:\s]*/,'')

	  # Insert ':' back into Mac Addr
	  re = /([0-9a-fA-F]{#{octs}})/
	  mac_a = mac.split(re)
	  mac_a.delete_if {|x| x == ''}
	  mac = mac_a.join("#{delimiter}")
	end
end
