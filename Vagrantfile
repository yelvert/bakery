Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  disk_id = 'disk2'
  disk_file = './sd_card.vmdk'

  if disk_id != ''
    mount_point_dir = '/dev'
    pid = `sudo launchctl list | grep diskarbitrationd | awk '{print $1}'`.strip
    system("sudo kill -SIGCONT #{pid}")
    Dir.entries(mount_point_dir).select{|d| d.start_with?("#{disk_id}s")}
      .each{|p| system("diskutil unmountDisk #{p}")}
    system("sudo chmod 0777 #{mount_point_dir}/#{disk_id}")
    system("sudo kill -SIGSTOP #{pid}")
  end

  config.vm.provider "virtualbox" do |vb|
    # Create SD Card mapping to a disk
    unless File.exist?(disk_file)
      vb.customize [
        'internalcommands',
        'createrawvmdk',
        '-filename', disk_file,
        '-rawdisk', "/dev/#{disk_id}"
        ]
    end

    # Attach SD Card image to the VM
    vb.customize [
      'storageattach', :id,
      '--storagectl', 'SCSI',
      '--port', 2,
      '--device', 0,
      '--type', 'hdd',
      '--medium', disk_file
    ]
  end

  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "playbook.yml"
  #   # ansible.verbose = "vv"
  #   # ansible.start_at_task = "Copy boot files to the first partition"
  #   ansible.ask_sudo_pass = true
  #   ansible.extra_vars = {
  #     local_disk_id: "#{disk_id}",
  #     make_image_file: "#{make_image_file}"
  #   }
  # end
  system("sudo kill -SIGCONT #{pid}")
end