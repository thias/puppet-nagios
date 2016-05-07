# This facter script adds the fact "nagios_smartmon" and puts there the hash
# that contain information about connected disks, controllers, their ports, etc.
# This information could be passed to the smartctl utility for checking the
# SMART status.
#
# Example of hashes:
#
# The SATA disks attached directly
# {
#   0=>{"dev"=>"sda", "controller"=>"ata"},
#   1=>{"dev"=>"sdb", "controller"=>"ata"}
# }
#
# The SATA disk connected to the LSI MegaRAID controller
# {
#   5=>{"interface"=>"SATA", "controller"=>"megaraid", "port"=>"1", "dev"=>"sda"},
#   0=>{"interface"=>"SATA", "controller"=>"megaraid", "port"=>"2", "dev"=>"sda"},
#   1=>{"interface"=>"SATA", "controller"=>"megaraid", "port"=>"0", "dev"=>"sda"},
#   2=>{"interface"=>"SATA", "controller"=>"megaraid", "port"=>"3", "dev"=>"sda"},
#   3=>{"interface"=>"SATA", "controller"=>"megaraid", "port"=>"4", "dev"=>"sda"},
#   4=>{"interface"=>"SATA", "controller"=>"megaraid", "port"=>"5", "dev"=>"sda"}
# }
#
# The SATA disk connected to the LSI MegaRAID controller
# {0=>{"dev"=>"sda", "interface"=>"SAS", "port"=>"8", "controller"=>"megaraid"}}


# Check if the RAID controller utility is present and get the full path to it.
def getRaidUtil(utilNames)
  raidUtil = nil

  utilNames.each do |name|
    if FileTest.exists?(name)
      raidUtil = name
    end
  end

  return raidUtil
end

# Controller megaraid
def getPhysicalDisksPorts_megaraid
  # List of possible names of RAID utility
  utilNames = [
    '/usr/sbin/megacli',
    '/usr/sbin/MegaCli',
    '/usr/sbin/MegaCli64'
  ]

  # Get the full path to RAID utility
  raidUtil = getRaidUtil(utilNames)

  # Check the connected ports only if the RAID utility is present.
  if raidUtil

    # Get the list of connected ports.
    physicalDisksPorts = Facter::Core::Execution.exec("#{raidUtil} -PDList -Aall | awk '/Device\ Id/{print $3}'")
    return physicalDisksPorts

  # Else return nil
  else
    return nil
  end
end

# This method checks the interface to which the disk is connected.
# This needed with the MegaRAID controllers in CentOS 6. The smartctl 5.43
# requires the "sat+megaraid,N" in case of SATA disk and just "megaraid,N" in
# case of SAS.
def checkDiskInterface(port)
  # List of possible names of RAID utility
  utilNames = [
    '/usr/sbin/megacli',
    '/usr/sbin/MegaCli',
    '/usr/sbin/MegaCli64'
  ]

  # Get the full path to RAID utility
  raidUtil = getRaidUtil(utilNames)

  # Get the disk interface (SATA/SAS)
  diskInterface = Facter::Core::Execution.exec("#{raidUtil} -PDList -aALL | grep -e '^Device Id: #{port}' -A 10 | awk '/PD Type:/{print $3}'")
end


# Controller hpsa
def getPhysicalDisksPorts_cciss
  # List of possible names of RAID utility
  utilNames = [
    '/usr/sbin/hpssacli',
    '/usr/sbin/hpacucli'
  ]

  # Get the full path to RAID utility
  raidUtil = getRaidUtil(utilNames)

  # Check the connected ports only if the RAID utility is present.
  if raidUtil

    # Get slot of SmartArray controller. This required for checking the connected ports.
    hpsaSlot = Facter::Core::Execution.exec("#{raidUtil} controller all show status | awk '/Slot/{print $6}'")

    # Get the list of connected ports.
    physicalDisksPorts = Facter::Core::Execution.exec("#{raidUtil} controller slot=#{hpsaSlot} physicaldrive all show status | awk '/bay/{ gsub(\",\",\"\"); print (\$6-1)}'")
    return physicalDisksPorts

  # Else return the nil
  else
    return nil
  end
end

# Get the list of connected disks and their attributes (name, port, interface).
def getDisks (controller)

  # Get the list of block devices and transform it to string divided by comma.
  blockdevices = Facter.value(:blockdevices).split(",")

  # Delete the CD-drive from array of blockdevices.
  # TODO: delete all CD-drives (sr*) and virtualdrives (vd*)
  blockdevices.delete('sr0')

  disks = {}
  diskInterface = nil

  # Controller "ata" in smartmontools terminology means that there is no any
  # hardware RAID controllers and disks are connected directly to the (S)ATA
  # ports
  if controller == "ata"
    i = 0

    # Add all blockdevices to the "disks" array.
    blockdevices.each do |blockdevice|
      disks[i] = {
        "dev"        => blockdevice,
        "controller" => controller
      }
      i += 1
    end
  else

    # Check the connected ports using the RAID controller utility (if present)
    ports = send("getPhysicalDisksPorts_#{controller}").split("\n")

    # If controller returned the list of non-empty ports then fill the "disks"
    # array. In other case do not add elements to array. This means that there
    # is no RAID controller utility and there is no way to check to which ports
    # disks are connected.
    if ports
      i = 0

      # Add all connected to RAID controller disks as separate devices to the
      # "disks" array. The smartctl requires the blockdevice for cheching the
      # SMART status. Let's pass the first blockdevice what we have to the
      # smartctl utility.
      ports.each do |port|

        # For the LSI MegaRAID controller we have to check the interface of the
        # disk. It may be SAS or SATA
        if controller == "megaraid"
          diskInterface = checkDiskInterface(port)
        end

        disks[i] = {
          "dev"        => blockdevices[0],
          "controller" => controller,
          "port"       => port,
          "interface"  => diskInterface
        }
        i += 1
      end
    end
  end

  return disks
end

Facter.add(:nagios_smartmon) do
  setcode do
    # Check if there is LSI MegaRAID controller
    if Facter.value(:nagios_pci_megaraid_sas)
      getDisks("megaraid")
    # Check if there is HP SmartArray controller
    elsif Facter.value(:nagios_pci_hpsa)
      getDisks("cciss")
    # Else use the "ata" driver
    else
      getDisks("ata")
    end
  end
end
