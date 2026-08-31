# Creates nagios_nvidia_gpu if nvidia-smi binary is found

if File.executable?('/bin/nvidia-smi') || File.executable?('/usr/bin/nvidia-smi')
  Facter.add('nagios_nvidia_gpu') do
    setcode { true }
  end
end