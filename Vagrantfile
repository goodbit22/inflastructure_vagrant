# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION  = "2"
require 'json'
machines_vag = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'machines_vagrant.json')))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	machines_vag.each do |machines|
		config.vm.define machines['name'] do |mav|
			mav.vm.box = machines['box']
			mav.vm.network  machines['type_net'] , ip: machines['ip_addr']
			
			if machines['name'] == "solaris11_3"
					mav.ssh.password = "1vagrant"
			end
			
			mav.vm.provider :virtualbox do |vb|
    		vb.name = machines['name']
        vb.memory = machines['ram']
        vb.customize ["modifyvm", :id, "--cpus", machines['vcpu']]
  			vb.customize ["modifyvm", :id, "--groups", "/systemy_praca_inz"]
				if machines['name'] == "redstaros"
					mav.ssh.username = "root"
					mav.ssh.password = "password"
					vb.customize ["modifyvm", :id, "--nic2", "none" ]
				end
  		end

 			if Vagrant.has_plugin?("vagrant-vbguest") then
    		config.vbguest.auto_update = false
  		end
			
			if machines['playbooks'] != ""
				mav.vm.provision "ansible" do |ansible|
					ansible.verbose = "v"
					ansible.playbook = machines['playbooks']
				  ansible.host_vars = {
       			machines['name'] => {
						 "ansible_winrm_scheme" => "http",                                                                   
						 "ansible_winrm_server_cert_validation" => "ignore" 
						}
					}   
				end
			end
		end
	end
end
