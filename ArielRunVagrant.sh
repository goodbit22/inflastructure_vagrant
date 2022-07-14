#!/usr/bin/bash
# shellcheck source=/dev/null

if [ -f vagrant_install.sh ]; then                                                                            
     source vagrant_install.sh                                                                                   
else                                                                                                          
	echo -e "${RED}vagrant_install.sh file cannot be found${WHITE}"                                        
    exit 1;                                                                                                     
 fi      


view_banner(){
   banner1=$(cat bannerAriel.txt)
   echo -e "${CYAN}$banner1 ${WHITE}"
}

check_exists_vagarant_machines(){
	local vagrant_machine="$1"
  for vm in "${list_virtual_machines[@]}"                                                                     
  do                                                                                                          
 		if [ "$vagrant_machine" == "$vm" ]; then                                                               
    	return 0                                                                                          
      break                                                                                             
    fi                                                                                                  
   done                                                                                                        
    return 1         
}

menu_run(){
	echo "1) ${BLUE}Uruchom wybrane maszyne zdefiniowane w Vagrantfile${WHITE}" 
	echo "2) ${BLUE}Uruchom wszystkie maszyny zdefiniowane w Vagrantfile${WHITE}"  
	echo "3) ${BLUE}Wroc${WHITE}" 
}

run_machines(){
	path_first_Vagrantfile=$(pwd)
	local options=("Uruchom wybrane maszyne zdefiniowane w Vagrantfile" "Uruchom wszystkie maszyny zdefiniowane w Vagrantfile" "Wroc" )
	PS3="Wybierz opcje: "
	echo "Wcisnij enter aby odswiezyc menu"
	select option in "${options[@]}" 
	do
		case $option in 
						"${options[0]}")
										echo "${CYAN}wybrales opcje $REPLY ${WHITE}"
										echo "${YELLOW}Lista dostepnych machine zdefiniowanych w plikach Vagrantfile${WHITE}"
										for name_machine in "${name_machines[@]}" 
										do
											echo "$name_machine"
										done
										for name_machine2 in "${name_machines_2[@]}"
										do
											echo "$name_machine2"
										done
										read -rp "${CYAN}Jaki maszyne wirtualna chcesz postawic${WHITE} " user_machine
										for name_machine in "${name_machines[@]}" 
										do
											if [ "$user_machine"  == "$(echo "$name_machine" | tr -d '"')"  ]; then
															vagrant up "$user_machine"
															break
											fi
										done
										for name_machine2 in "${name_machines_2[@]}" 
										do
											if [ "$user_machine"  == "$name_machine2"  ]; then
															cd "$path_first_Vagrantfile/metasploitab3" || return 1
															vagrant up "$user_machine"
															cd "$path_first_Vagrantfile" || return 1        
															break
											fi
										done
										menu_run
										;;
						"${options[1]}")
										echo "${CYAN}wybrales opcje $REPLY ${WHITE}"
										echo "${GREEN}stawianie maszyn wirtualnych zawartych w pliku Vagrantfile${WHITE}"
										vagrant up
										VBoxManage modifyvm "redstaros" --nic1 "intnet"
										echo "${GREEN}stawienie maszyn wirtualnych zawartych w pliku  metasploitab3/Vagrantfile${WHITE}"
										cd "$path_first_Vagrantfile/metasploitab3" || return 1
										vagrant up   
										cd "$path_first_Vagrantfile" || return 1
										menu_run
										;;
						"${options[2]}")
										echo "${CYAN}wybrales opcje $REPLY ${WHITE}"
										break	
										;;
						*) echo "nie ma takiej opcji $REPLY";;
		esac
	done
}

shutdown_machines(){
	path_first_Vagrantfile=$(pwd)
	vagrant halt 
	cd "$path_first_Vagrantfile/metasploitab3" || return 1
	vagrant halt 
	cd "$path_first_Vagrantfile" || return 1
   
}

save_machines(){
	path_first_Vagrantfile="$PWD"
	vagrant suspend
	cd "$path_first_Vagrantfile/metasploitab3" || return 1
 	vagrant suspend 
	cd "$path_first_Vagrantfile" || return 1

}

menu_delete(){
	echo "1) ${BLUE}Usun wybrane maszyne zdefiniowane w Vagrantfile${WHITE}" 
	echo "2) ${BLUE}Usun wszystkie maszyny zdefiniowane w Vagrantfile${WHITE}"  
	echo "3) ${BLUE}Wroc${WHITE}" 
}

delete_machines(){
	path_first_Vagrantfile=$(pwd)
	local options=("Usun wybrane maszyne zdefiniowane w Vagrantfile" "Usun wszystkie maszyny zdefiniowane w Vagrantfile" "Wroc" )
	PS3="Wybierz opcje: "
	echo "Wcisnij enter aby odswiezyc menu"
	select option in "${options[@]}" 
	do
		case $option in 
						"${options[0]}")
										echo "${CYAN}wybrales opcje $REPLY ${WHITE}"
										vagrant destroy 
										cd "$path_first_Vagrantfile/metasploitab3" || return 1
										vagrant destroy 
										cd "$path_first_Vagrantfile" || return 1
										menu_delete
										;;
						"${options[1]}")
										echo "${CYAN}wybrales opcje $REPLY ${WHITE}"
										echo "${GREEN}usuwanie maszyn zdefiniowanych w pliku  pliku Vagrantfile${WHITE}"
										vagrant destroy -f 
										cd "$path_first_Vagrantfile/metasploitab3" || return 1
										echo "${GREEN}usuwanie maszyn zdefiniowanych  w pliku metasploitab3/Vagrafile${WHITE}"
										vagrant destroy -f
										cd "$path_first_Vagrantfile" || return 1
										menu_delete
										;;
						"${options[2]}")
										echo "${CYAN} wybrales opcje $REPLY ${WHITE}"
										break	
										;;
						*) echo "${YELLOW}invalid option$REPLY ${WHITE}";;
		esac
	done
}

inside_network(){
				for name_machine in "${name_machines[@]}" 
				do
					if [ "$name_machine" == "redstaros" ];then 
						echo "${YELLOW}pominieto redstaros w tym procesie poniewaz ma tylko jeden interfejs${WHITE}"	
					else
						check_exists_vagarant_machines "$(echo "$name_machine" | tr -d '"' )"  
						local status="$?"
						if [ "$status" -eq 0 ];then 
							VBoxManage modifyvm  "$(echo "$name_machine" | tr -d '"' )" --nic2 "intnet"   	
							echo  "${GREEN}Ustawiono internal network na nic2 w maszynie wirtualnej $name_machine ${WHITE}"
							VBoxManage modifyvm  "$(echo "$name_machine" | tr -d '"' )" --nic1 "null"   	
							echo  "${GREEN}Wylaczono interfejs nic1 w maszynie wirtualnej $name_machine ${WHITE}"
						fi
					fi
				done
				for name_machine2 in "${name_machines_2[@]}" 
				do
						check_exists_vagarant_machines "$name_machine2"  
						local status="$?"
						if [ "$status" -eq 0 ];then 
							VBoxManage modifyvm  "$name_machine2" --nic2 "intnet"   	
							echo  "${GREEN}Ustawiono internal network na nic2 w maszynie wirtualnej $name_machine2 ${WHITE}"
							VBoxManage modifyvm  "$name_machine2" --nic1 "null"   	
							echo  "${GREEN}Wylaczono interfejs nic1 w maszynie wirtualnej $name_machine2 ${WHITE}"
						fi
				done
}

hostonly_network(){
				for name_machine in "${name_machines[@]}" 
				do
					if [ "$name_machine" == "redstaros" ];then 
						echo "${YELLOW}pominieto redstaros w tym procesie poniewaz ma tylko jeden interfejs${WHITE}"	
					else
						check_exists_vagarant_machines "$(echo "$name_machine" | tr -d '"' )"  
						local status="$?"
						if [ "$status" -eq 0 ];then 
							VBoxManage modifyvm  "$(echo "$name_machine" | tr -d '"' )" --nic2 "hostonly"  &> /dev/null 	
							echo  "${GREEN}Ustawiono host-only na nic2 w maszynie wirtualnej $name_machine ${WHITE}"
							VBoxManage modifyvm  "$(echo "$name_machine" | tr -d '"' )" --nic1 "nat"   	
							echo  "${GREEN}Ustawiono nat na nic1 w maszynie wirtualnej $name_machine ${WHITE}"
						fi
					fi
				done
				for name_machine2 in "${name_machines_2[@]}" 
				do
						check_exists_vagarant_machines "$name_machine2" 
						local status="$?"
						if [ "$status" -eq 0 ];then 
							VBoxManage modifyvm  "$name_machine2" --nic2 "hostonly"  &> /dev/null 	
							echo  "${GREEN}Ustawiono host-only na nic2 w maszynie wirtualnej $name_machine2 ${WHITE}"
							VBoxManage modifyvm  "$name_machine2" --nic1 "nat"   	
							echo  "${GREEN}Ustawiono nat na nic1 w maszynie wirtualnej $name_machine2 ${WHITE}"
						fi
				done
}

bridge_network(){
	ansbile_machines=("kali" "win7" "win8_1" "win10" "win_server_2016" "fedora33" "ubuntu-21.10")
	for ansible_machine in "${ansbile_machines[@]}"
	do
		check_exists_vagarant_machines "$(echo "$ansible_machine" | tr -d '"' )"  
		local status="$?"
		if [ "$status" -eq 0 ];then
						VBoxManage modifyvm  "$(echo "$ansible_machine" | tr -d '"' )" --nic1 "bridged"   	
						echo  "${GREEN}Ustawiono bridged na nic1 w maszynie wirtualnej $ansible_machine${WHITE}"
		fi			 	
	done	
}

menu(){
	echo "1) ${BLUE}Run virtual machines${WHITE}" 
	echo "2) ${BLUE}Switch off virtual machines${WHITE}"  
	echo "3) ${BLUE}Save status virtual machines${WHITE}" 
	echo "4) ${BLUE}Remove virtual machines${WHITE}"  
	echo "5) ${BLUE}Switch network interfaces on internal network ${WHITE}" 
	echo "6) ${BLUE}Switch network interfaces on host-only ${WHITE}"  
	echo "7) ${BLUE}Switch network interfaces on bridge${WHITE}"  
	echo "8) ${BLUE}QUIT${WHITE}"
}

main_function(){
	local options=("${BLUE}Run virtual machines${WHITE}" "${BLUE}Switch off virtual machines${WHITE}" 
					"${BLUE}Save status virtual machines${WHITE}" "${BLUE}Remove virtual machines${WHITE}" 
					"${BLUE}Switch network interfaces on internal network ${WHITE}" 
					"${BLUE}Switch network interfaces on host-only ${WHITE}" 
					"${BLUE}Switch network interfaces on bridge${WHITE}" "${BLUE}QUIT${WHITE}")
	PS3="${CYAN}Select option: ${WHITE}"
	clear
	view_banner
	vagrant_install
	mapfile -t name_machines < <(cat < machines_vagrant.json | jq  '.[]["name"]')
	name_machines_2=("metasploitable3-ub1404" "metasploitable3-win2k8")
	mapfile -t list_virtual_machines < <(VBoxManage list vms | awk '{print $1}' | sed 's/"//g')
	COLUMNS=12
	select option in "${options[@]}" 
	do
		case $option in 
						"${options[0]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										run_machines
										menu
										;;
						"${options[1]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										shutdown_machines
										menu
										;;
						"${options[2]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										save_machines
										menu
										;;
						"${options[3]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										delete_machines
										menu
										;;
						"${options[4]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										inside_network
										menu
										;;
						"${options[5]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										hostonly_network
										menu
										;;
						"${options[6]}")
										echo "${CYAN}you have chosen $REPLY option ${WHITE}"
										bridge_network
										menu
										;;
						"${options[7]}")
										break	
										;;
						*) 
										clear
										COLUMNS=12
										menu
										echo "${YELLOW}invalid option$REPLY ${WHITE}"
										;;
		esac
	done
}
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
WHITE=$(tput setaf 7)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)

main_function
