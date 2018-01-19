# **********************************************************
#
# sweep_cmts.rb
#
# Purpose:
# => Queries cable modem for a list of stats.  Returns
# => those stats to the cmts model
#

require 'eventmachine'
require 'snmp4em'

class Sweep
	include ApplicationHelper
	def initialize(iplist, community, timeout=5, retries=1)
		@result = []
		@iplist = iplist
		@community = community
		@timeout=timeout
		@retries=retries
	end

	# Formats results into array or hashes.
	def writeHistory()
		$target_stats.each do |k,v|
			@result.push({k=>v})
		end
	end

	# Exit our Machine if we've evaluated all CPE Hosts
	def doExit(ctr, total)
		# if ctr (queried so far) equals total to query
		# call method to format and write to stdout
		if (ctr == total)
			writeHistory()
			EM.stop
		end
	end

	def perform()
		# ----------------------------------------------
		#
		# MAIN Routine
		#
		#

		# Variables, OIDs to query cable modem
		oid_TX	= "1.3.6.1.2.1.10.127.1.2.2.1.3.2"
		oid_RX	= "1.3.6.1.2.1.10.127.1.1.1.1.6.3"
		oid_SNR = "1.3.6.1.2.1.10.127.1.1.4.1.5.3"
		oid_MR  = "1.3.6.1.2.1.10.127.1.1.4.1.6.3"
		oid_RESETS = "1.3.6.1.2.1.10.127.1.2.2.1.4.2"
		oid_CM_RECV_INVALID_RANGING_RESPONSES = "1.3.6.1.2.1.10.127.1.2.2.1.8.2"
		oid_CM_RECV_INVALID_REGISTRATION_RESPONSES = "1.3.6.1.2.1.10.127.1.2.2.1.9.2"
		oid_CM_CMTS_ABORTED_RANGINGS = "1.3.6.1.2.1.10.127.1.2.2.1.14.2"
		oid_CM_DS_RF_BYTES     = "1.3.6.1.2.1.2.2.1.10.3"
		oid_CM_US_RF_BYTES     = "1.3.6.1.2.1.2.2.1.16.4"
		oid_CM_DS_RF_ERR_BYTES = "1.3.6.1.2.1.2.2.1.14.3"
		oid_CM_US_RF_ERR_BYTES = "1.3.6.1.2.1.2.2.1.20.4"
		oid_CM_DS_ETH_BYTES    = "1.3.6.1.2.1.2.2.1.10.1"
		oid_CM_US_ETH_BYTES    = "1.3.6.1.2.1.2.2.1.16.1"

		# Global variables
		$target_stats = {} # Holds our CPE stats
#		$retries = {} #
		$timedout = Array.new()

		# Start Event Machine
		EventMachine.run {

			# Initialize increment counter
			ctr = 0

			# Each IP
			@iplist.each do |ip|

				# Create new hash key for this IP if one does not already exist
			  if (!$target_stats.has_key?(ip))
			  	$target_stats[ip] = {:down => 0, :up => 0}
			  end

			  # Open SNMP session with CPE
			  snmp = SNMP4EM::Manager.new(:host => ip, :community => @community, :version => :SNMPv2c, :timeout => @timeout, :retries => @retries )

			  # Make request to CPE
			  cperequest = snmp.get([oid_TX, oid_RX, oid_SNR, oid_MR, oid_RESETS,
									 oid_CM_RECV_INVALID_RANGING_RESPONSES,
									 oid_CM_RECV_INVALID_REGISTRATION_RESPONSES,
									 oid_CM_CMTS_ABORTED_RANGINGS,
									 oid_CM_DS_RF_BYTES,
									 oid_CM_US_RF_BYTES,
									 oid_CM_DS_RF_ERR_BYTES,
									 oid_CM_US_RF_ERR_BYTES,
									 oid_CM_DS_ETH_BYTES,
									 oid_CM_US_ETH_BYTES,])

			  # Response Callback, process
			  cperequest.callback do |response|
					ctr += 1

					# Copy response values into local var.  Calc where needed
			  	up							= response[oid_TX].to_f / 10
			  	down 						= response[oid_RX].to_f / 10
			  	snr  						= response[oid_SNR].to_r * 0.10
			  	mr   						= response[oid_MR]
			  	resets					= response[oid_RESETS]
					irr 						= response[oid_CM_RECV_INVALID_RANGING_RESPONSES]
					iregr 					= response[oid_CM_RECV_INVALID_REGISTRATION_RESPONSES]
					ar 							= response[oid_CM_CMTS_ABORTED_RANGINGS]
					ds_rf_bytes 		= response[oid_CM_DS_RF_BYTES]
					us_rf_bytes 		= response[oid_CM_US_RF_BYTES]
					ds_rf_err_bytes = response[oid_CM_DS_RF_ERR_BYTES]
					us_rf_err_bytes = response[oid_CM_US_RF_ERR_BYTES]
					ds_eth_bytes 		= response[oid_CM_DS_ETH_BYTES]
					us_eth_bytes 		= response[oid_CM_US_ETH_BYTES]

					# Copy processed responses into global responses hash
			  	$target_stats[ip][:up]							= up
			  	$target_stats[ip][:down] 						= down
			  	$target_stats[ip][:cpe_snr]  				= snr.round(2)
					$target_stats[ip][:mr]							= mr
					$target_stats[ip][:resets]					= resets
					$target_stats[ip][:irr]							= irr
					$target_stats[ip][:iregr]						= iregr
					$target_stats[ip][:ar]							= ar
					$target_stats[ip][:ds_rf_bytes]			= ds_rf_bytes
					$target_stats[ip][:us_rf_bytes]			= us_rf_bytes
					$target_stats[ip][:ds_rf_err_bytes]	= ds_rf_err_bytes
					$target_stats[ip][:us_rf_err_bytes]	= us_rf_err_bytes
					$target_stats[ip][:ds_eth_bytes]		= ds_eth_bytes
					$target_stats[ip][:us_eth_bytes]		= us_eth_bytes

					# Check and exit
					doExit(ctr,@iplist.length)
			  end

			  # If Callback timed out
			  cperequest.errback do |error|
					ctr += 1

					# Update timedout global
					$timedout.push(ip)

					# Check and exit
					doExit(ctr,@iplist.length)
			  end

			  # Clear memory
			  request = nil
			  snmp = nil
			end
		}

		# Log CPE that timed out
		if ($timedout.length > 0)
			$timedout.each do |e|
				ld("CPE IP (#{e}) timed out!")
			end
		end

		# Return result
		return @result
	end
end
