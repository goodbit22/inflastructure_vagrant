#!/bin/bash 

view_banner(){
    echo "                           
#   #    ##   #    # #    #   ##   
#  #    #  #  ##   # ##   #  #  #  
###    #    # # #  # # #  # #    # 
#  #   ###### #  # # #  # # ###### 
#   #  #    # #   ## #   ## #    # 
#    # #    # #    # #    # #    # 
    "
}

cewl_usage(){
    echo "Tworzenie słownikow wykorzystujac narzedzie cewl"
    if [ ! -f  '/usr/share/wordlists/dictionary_cewl_linux.txt' ]; then 
        echo "Tworzenie słownikow wykorzystujac narzedzie cewl"
        cewl https://www.linux.org/ -d 0  -w /usr/share/wordlists/dictionary_cewl_linux.txt
    fi
    if [ ! -f '/usr/share/wordlists/dictionary_cewl_win.txt' ]; then 
        echo "Tworzenie słownikow wykorzystujac narzedzie cewl"
        cewl https://www.microsoft.com/pl-pl/ -d 0  -w /usr/share/wordlists/dictionary_cewl_win.txt
    fi
}

crunch_usage(){
    if [ !  -f  "/usr/share/wordlists/dictionary_crunch.txt" ]; then
        echo "Tworzenie słownika wykorzystujac narzedzie crunch"
        crunch 3 5  abcdefghijklmnopqrstuvwxyz  -o /usr/share/wordlists/dictionary_crunch.txt
    else 
        echo "Juz wczesniej wygenerowano slownik za pomoca crunch"
    fi
}

pydictor_usage(){
    current_path="${PWD}"
    if [ ! -f '/usr/share/wordlists/dictionary_pydictor.txt' ]; then
        echo "Tworzenie słownika wykorzystujac narzedzie  pydictor"
        cd "/home/vagrant/softwares/pydictor" || exit 1
        sudo python pydictor.py --len 3 5 -base d  -o /usr/share/wordlists/dictionary_pydictor.txt
        cd "${current_path}" || exit 1
    else
        echo "Juz wczesniej wygenerowano slownik za pomoca pydictor"
    fi
}

dymerge_usage(){    
    current_path="${PWD}"
    cd "/home/vagrant/softwares/dymerge" || exit 1
    echo "Laczenie słownikow wykorzystujac narzedzie dymerge"    

    if [ ! -f '/usr/share/wordlists/password_dictionary_all.txt' ]; then 
        echo "Trwa laczenie slownikow z haslami  w jeden slownik"
      sudo python dymerge.py  /usr/share/wordlists/dictionary_pydictor.txt /usr/share/wordlists/dictionary_crunch.txt  \
    /usr/share/wordlists/dictionary_cewl_win.txt /usr/share/wordlists/dictionary_cewl_linux.txt  /usr/share/wordlists/enable1.txt  \
    /usr/share/wordlists/popular.txt /usr/share/wordlists/dictionary.txt /usr/share/wordlists/PasswordDictionary.txt  /usr/share/wordlists/10-million-password-list-top-1000000.txt \
		/usr/share/wordlists/bruteforce-database/1000000-password-seclists.txt /usr/share/wordlists/bruteforce-database/uniqpass-v16-passwords.txt \
    -u -s -o /usr/share/wordlists/password_dictionary_all.txt
    else
        echo "Juz wczesniej zloczono slowniki z haslami w jeden slownik"
    fi
        
    if [ ! -f '/usr/share/wordlists/login_dictionary_all.txt' ]; then 
      echo "Trwa laczenie slownikow z loginami w jeden slownik"
    sudo python dymerge.py /usr/share/wordlists/metasploit/unix_users.txt /usr/share/wordlists/metasploit/snmp_default_pass.txt /usr/share/wordlists/metasploit/ipmi_users.txt \
    /usr/share/wordlists/metasploit/default_users_for_services_unhash.txt  /usr/share/wordlists/metasploit/mirai_user.txt  /usr/share/wordlists/metasploit/mirai_user.txt \
		/usr/share/wordlists/bruteforce-database/usernames.txt /usr/share/wordlists/bruteforce-database/38650-username-sktorrent.txt \
		-u -s -o /usr/share/wordlists/login_dictionary_all.txt
    else
        echo "Juz wczesniej zloczono slowniki z loginami w jeden slownik"
    fi
    cd "${current_path}" || exit 1  
}

dictionary_download(){
    directory='/usr/share/wordlists/'
    echo "Trwa sciaganie slownikow"
    dictories=('https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt' 
    )
    for dict in "${dictories[@]}"
    do
        if  [ ! -f "${directory}${dict##*/}" ]; then
            wget -P "${directory}" "${dict}"                                                                   
        fi 
    done
    echo "Trwa sciaganie rozbudowanej bazy slownikow"
    brute_database="https://github.com/duyet/bruteforce-database"
    if [ ! -d  "${directory}${brute_database##*/}" ]; then
        git clone "${brute_database}" "${directory}${brute_database##*/}" 
    fi 
    echo "Trwa rozpokowywanie zarchiwizowanych slownikow"
		if [ -f "${directory}rockyou.txt.gz" ]; then
    	sudo gzip -d "${directory}rockyou.txt.gz" 
		
		fi
}

main(){
   view_banner
   cewl_usage
   crunch_usage
   pydictor_usage
   dictionary_download
   dymerge_usage
}
if [ "$UID" -eq 0 ];then
	main
else
	echo "Uruchom skrypt za pomoca sudo"
fi





