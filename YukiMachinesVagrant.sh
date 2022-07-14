#!/usr/bin/bash
# shellcheck source=/dev/null

if [ -f vagrant_install.sh ]; then
	source vagrant_install.sh
else
	echo -e "${RED}vagrant_install.sh file cannot be found${WHITE}"                                        
	exit 1;
fi

view_banner(){
	banner1=$(cat  bannerYuki.txt)
	echo -e "${CYAN}$banner1 ${WHITE}"
}

menu(){
	echo -e "1) ${BLUE}Add Boxes${WHITE}"
	echo -e "2) ${BLUE}Init Boxes${WHITE}"
	echo -e "3) ${BLUE}Delete Boxes${WHITE}"
	echo -e "4) ${BLUE}Delete files Vagrantfile${WHITE}"
	echo -e "5) ${BLUE}Update vagrant boxes${WHITE}"
	echo -e "6) ${BLUE}Quit${WHITE}"
}

main(){
		clear
		view_banner
		vagrant_install
		PS3="${CYAN}Please enter your choice:${WHITE} "
		options=("${BLUE}Add Boxes${WHITE}" "${BLUE}Init Boxes${WHITE}" "${BLUE}Delete Boxes${WHITE}" 
						"${BLUE}Delete files Vagrantfile${WHITE}" "${BLUE}Update vagrant boxes${WHITE}" "${BLUE}Quit${WHITE}")
		export local COLUMNS=13  			
select opt in "${options[@]}"
do
    case $opt in
        "${options[0]}")
						add_vagrant_boxes
						menu
            ;;
        "${options[1]}")
						init_machines_vagrant
            menu
						;;
        "${options[2]}")
						delete_vagrant_boxes
            menu
						;;
        "${options[3]}")
						delete_files_vagrant
            menu
						;;
        "${options[4]}")
						update_vagrant_boxes
            menu
						;;
        "${options[5]}")
            break
            ;;
        *) 
					 clear
					 echo "${YELLOW}invalid option $REPLY ${WHITE}"
					 menu		
					 ;;
    esac
done
}

check_exists_vagrant_boxes(){
	local machine="$1"
	mapfile -t  list_vagrant_box < <(vagrant box list | awk '{print $1 }') 
	for machine_v in "${list_vagrant_box[@]}"
	do
			if [ "$machine" == "$machine_v" ]; then
							return 1
							break
			fi
	done
	return 0
}

add_vagrant_boxes(){
				if [ -d ~/machines_vagrant ];then
					true
				else
					mkdir ~/machines_vagrant
					echo -e "${GREEN}Utworzono katalog machines_vagrant w katalogu domowym${WHITE}"
				fi
				cd ~/machines_vagrant || return 1
				for machine in "${list_machines[@]}"
				do
						check_exists_vagrant_boxes "$machine"
						local response="$?"
						if [ "$response" -eq 0 ]; then
								vagrant box add  "$machine" --provider "virtualbox"  
								echo -e "${GREEN} Dodano nowy Box $machine ${WHITE}"
						else
								echo -e "${YELLOW} Podany box $machine juz istnieje ${WHITE}"
						fi
				done
				cd "$script_catalog" || return 1

}

temp_init(){
		local name="$1"
		local name_vagrant_file="$2"
		cd "$name" || return 1
		if [ -e "$name_vagrant_file" ];then
			echo -e "${YELLOW}Plik konfiguracji vagrant ${name_vagrant_file##*/}  juz wczesniej został utworzony${WHITE}"
			cd ..
		else
			vagrant init --output "${name_vagrant_file##*/}"
			echo -e "${GREEN}Utworzono plik konfiguracyjny vagrant ${name_vagrant_file##*/} ${WHITE}"
			cd ..
		fi
}

init_machines_vagrant(){
				local directory="virtual_machines_vagrant_conf"
				if [ -d "../${directory}" ];then
					echo -e "${GREEN}Utworzono katalog $directory ${WHITE}"
				else
					mkdir "../${directory}"
					echo -e "${GREEN}Utworzono katalog $directory ${WHITE}"
				fi
				cd "../${directory}" || return 1
				for machine_i in "${list_machines[@]}"
				do
					local name="${machine_i##*/}"
					if [ -d "$name" ]; then
						echo -e "${YELLOW}Katalog $name  juz wczesniej został utworzony${WHITE}"
						local name_vagrant_file="${name}/Vagrantfile_${name}"
						temp_init "$name" "$name_vagrant_file"
					else
						mkdir "$name"
						echo -e "${GREEN}Utworzono katalog $name ${WHITE}"
						local name_vagrant_file="${name}/Vagrantfile_${name}"
						temp_init "$name" "$name_vagrant_file"
					fi
				done
				cd "$script_catalog" || return 1

}

delete_vagrant_boxes(){
				for machine_r in "${list_machines[@]}"
				do
						check_exists_vagrant_boxes "$machine_r"
						local response="$?"
						if [ "$response" -eq 1 ]; then
								vagrant box remove "$machine_r"
								echo -e "${GREEN} Usunieto   Box $machine_r ${WHITE}\n"
						else
								echo -e "${RED} Podany box $machine_r nie istnieje ${WHITE}\n"
						fi
				done
}

delete_files_vagrant(){
				local directory="virtual_machines_vagrant_conf"
				if [ -d "../${directory}" ];then
								rm -r "../${directory}"
								echo -e "${GREEN}Podany katalog został usuniety  z cała jego zawartoscia${WHITE}"
				else
					echo -e "${RED}Nie udalo sie usunac katalogu." 
					echo -e "Podany katalog $directory nie istnieje ${WHITE}\n"
				fi
}

update_vagrant_boxes(){
	vagrant box update
}

script_catalog="$PWD"
mapfile -t list_machines < <( cat vagrant_box.txt )

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
WHITE=$(tput setaf 7)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)

main
