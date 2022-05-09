#!/bin/bash

#メニュー
options[0]="option 1"
options[1]="option 2"
options[2]="option 3"
options[3]="option 4"
options[4]="option 5"

#各メニューごとに挙動を記述する
function DOIT {
	if [[ ${choices[0]} ]]; then
		echo "Option 1 selected"
	fi

	if [[ ${choices[1]} ]]; then
		echo "Option 2 selected"
	fi

	if [[ ${choices[2]} ]]; then
		echo "Option 3 selected"
	fi

	if [[ ${choices[3]} ]]; then
		echo "Option 4 selected"
	fi

	if [[ ${choices[4]} ]]; then
		echo "Option 5 selected"
	fi
}

clear

#現在フォーカスしているメニュー
current_line=0

#メニュー一覧を表示
function MENU {
	echo "移動:[↑]or[↓], 選択:[SPACE], 決定:[ENTER]"
	for NUM in ${!options[@]}; do
		if [ $NUM -eq $current_line ]; then
			echo -n ">"
		else
			echo -n " "
		fi
		echo "[${choices[NUM]:- }]"":${options[NUM]}"
	done
}


#メニュー選択のループ
function SELECT_LOOP {
	while true; do
		while MENU && IFS= read -r -n1 -s SELECTION && [[ -n "$SELECTION" ]]; do
			if [[ $SELECTION == $'\x1b' ]]; then
				read -r -n2 -s rest
				SELECTION+="$rest"
			fi	
			clear
		
			case $SELECTION in
				$'\x1b\x5b\x41') #up arrow
					if [[ $current_line -ne 0 ]]; then
						current_line=$(( current_line - 1 ))
					else
						current_line=$(( ${#options[@]}-1 ))
					fi
					;;
				$'\x1b\x5b\x42') #down arrow
					if [[ $current_line -ne $(( ${#options[@]}-1 )) ]]; then
						current_line=$(( current_line + 1 ))
					else
						current_line=0
					fi
					;;
				$'\x20') #space
					if [[ "${choices[current_line]}" == "+" ]]; then
						choices[current_line]=""
					else
						choices[current_line]="+"
					fi
					;;
			esac
		done

		read -p "選べた? [Y/n]" Answer
		case $Answer in
			'' | [Yy]* )
				break;
				;;
			[Nn]* )
				;;
			* )
				echo "YES or NOで答えてね"
				;;
		esac
		clear
	done
}

SELECT_LOOP
DOIT
