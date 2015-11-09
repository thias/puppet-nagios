# Based on the original ipaddress6 fact, but we also exclude addresses on the
# loopback interface and RFC4193 local (private) IPv6 addresses, then pick the
# shortest address to prefer static over autoconfiguration.

# Aux funcion to filter RFC4193 addresses
def valid_addr?(addr)
  not (addr =~ /^fe80.*/ or addr =~ /^fd.*/)
end

if Facter.version.to_f < 3.0
  require 'facter/util/ip'

  def get_address_after_token(output, token)

    String(output).scan(/#{token}\s?((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4})/).
      select { |match| valid_addr?(match.first) }.
      flatten.
      sort_by { |x| x.length }.
      shift
  end

  Facter.add(:nagios_ipaddress6) do
    setcode do
      output=Facter::Util::IP.get_interfaces.reject { |i,_| i =~ /lo.*/ }.map { |i| Facter::Util::IP::get_single_interface_output(i) }.join("\n")
      get_address_after_token(output, 'inet6(?: addr:)?')
    end
  end

else
  Facter.add(:nagios_ipaddress6) do
    setcode do
      Facter.value(:networking)['interfaces'].
        reject { |i,_| i =~ /lo.*/ }.
        values.
        map { |x| x['bindings6'] }.
        flatten.
        map { |x| x['address'] }.
        select { |x| valid_addr? x }.
        sort_by { |x| x.length }.
        shift
    end
  end
end
