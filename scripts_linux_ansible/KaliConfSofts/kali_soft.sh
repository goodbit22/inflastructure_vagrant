#!/bin/bash
install_packages(){
	#urls=("")
	cd softwares || exit 1
	#for url in "${urls[@]}"
	#do
	#			echo "Trwa pobieranie: $url ${url##*/}"
	#			curl "$url" --output "${url##*/}"
	#done
	
	urls_git=("https://github.com/vulnersCom/nmap-vulners" 
					"https://github.com/scipag/vulscan" "https://github.com/LandGrey/pydictor" "https://github.com/k4m4/dymerge")
	for url_git in "${urls_git[@]}"
	do
				echo "Trwa klonowanie: $url_git"
				if [ "$url_git" == 'https://github.com/vulnersCom/nmap-vulners' ] || [ "$url_git" == 'https://github.com/scipag/vulscan' ]; then
					if [ ! -f  "/usr/share/nmap/scripts/${url_git##*/}" ]; then
						git clone "$url_git" "/usr/share/nmap/scripts/${url_git##*/}"
					fi
				else
					if [ ! -f "${url_git##*/}" ];then
						git clone "$url_git"
					fi
				fi
	done
	nmap --script-updatedb
	dictionaries=("https://gist.githubusercontent.com/jaymo107/a21eab7c8eb613f10c664df0a309039a/raw/ec9669870b097a3f9cb8407fa7430904fd991487/dictionary.txt"
	"https://raw.githubusercontent.com/dolph/dictionary/master/unix-words" 'https://raw.githubusercontent.com/dolph/dictionary/master/enable1.txt'
	'https://raw.githubusercontent.com/dolph/dictionary/master/popular.txt' 
	'https://gist.github.com/PeterStaev/e707c22307537faeca7bb0893fdc18b7/raw/6c591618b8c0c46cb7db7a6966754455164cb433/PasswordDictionary.txt'
	)
	for dict in "${dictionaries[@]}"
	do
		if [ ! -f "/usr/share/wordlists/${dict##*/}" ];then
			wget -P '/usr/share/wordlists/' "$dict"
		fi
	done

}

install_packages
