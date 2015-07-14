# Based on the original ipaddress6 fact, but we also exclude RFC4193 local
# (private) IPv6 addresses and pick the shortest address to prefer static over
# autoconfiguration.

require 'facter/util/ip'

def get_address_after_token(output, token)
  ip = []
  String(output).scan(/#{token}\s?((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).each do |match|
    match = match.first
    unless match =~ /^fe80.*/ or match =~ /^fd.*/ or match == "::1"
      ip << match
    end
  end
  if ip.empty?
    nil
  else
    ip.sort_by{|s| s.length }[0]
  end
end

Facter.add(:nagios_ipaddress6) do
  setcode do
    output = Facter::Util::IP.exec_ifconfig(["2>/dev/null"])
    get_address_after_token(output, 'inet6(?: addr:)?')
  end
end

