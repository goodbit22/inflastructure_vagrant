#"vagrant-winnfsd"
installed_software(){
	local softwares=("virtualbox" "vagrant"  "ansible")
	echo "${YELLOW}Trwa aktualizacja repozytoriow${WHITE}"
	sudo apt update &> '/dev/null' 
	for software in "${softwares[@]}"
	do
		echo "Trwa sprawdzanie czy program $software wczesniej byl zainstalowany "
		sudo dpkg-query -l "$software" &> "/dev/null"
		if [ "$?" ] ;then
			echo "${YELLOW}Program $software byl juz zainstalowany${WHITE}"
		else
			echo "${BLUE}rozpoczeto  instalacje $software ${WHITE}"
			sudo apt install -y "$software"  &> "/dev/null"
			echo "${GREEN} zakonczono  instalacje $software ${WHITE}"
		fi
	done
}

vagrant_install(){
	mapfile -t list_plugin_ins_vag < <(vagrant plugin list | awk '{print $1}')       
	installed_software
	local vagrant_plugins=("vagrant-vbguest")
	for plugin in "${vagrant_plugins[@]}"
	do
		plugin_ins=0
		for plug in  "${list_plugin_ins_vag[@]}" 
		do
			if [ "$plugin" == "$plug" ]; then
				plugin_ins=1
				break
			fi
		done	
		if [ "$plugin_ins" -eq 0 ]; then
			vagrant plugin install "$plugin" &> "/dev/null"
			echo -e "${GREEN}zainstalowano plugin $plugin${WHITE}"
		fi
	done
}
GREEN=$(tput setaf 2)                                                                                         
BLUE=$(tput setaf 4)                                                                                          
WHITE=$(tput setaf 7)                                                                                         
YELLOW=$(tput setaf 3)                                                                                        
BLUE=$(tput setaf 4)                                                                                          
