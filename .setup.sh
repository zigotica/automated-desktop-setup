#!/usr/bin/env bash

# Automated desktop setup, v1.0.0
# Sergi Meseguer <zigotica@gmail.com>
#
# Inspired by / heavily modified from:
# https://github.com/thoughtbot/laptop/
# https://github.com/mathiasbynens/dotfiles/
# https://github.com/LukeSmithxyz/LARBS
#

############################################################################
# UTILS
############################################################################

# Reusable defaults
dryrun=1
silent=0
answer=""

# Indicator for boolean question replies
green="$(tput setaf 2)"
reset="$(tput sgr0)"
options_def_true=$(echo -ne "(options: ${green}\e[4mY\e[0m${green}es${reset} \e[4mN\e[0mo \e[4mS\e[0mkip \e[4mQ\e[0muit")
options_def_false=$(echo -ne "(options: \e[4mY\e[0mes ${green}\e[4mN\e[0m${green}o${reset} \e[4mS\e[0mkip \e[4mQ\e[0muit")
options_end=$(echo -ne ")")
current_intro=" - current value:"

# Spacer / title utils
spacer() {
    [[ $1 == "h1" ]] && echo " ############################################################################";
    [[ $1 == "h2" ]] && echo " ----------------------------------------------------------------------------";
}

h1() {
    echo; echo; spacer "h1"; echo "  $1"; spacer "h1";
}

h2() {
    echo; spacer "h2"; echo "  $1"; spacer "h2"; echo;
}

# Detect -f required argument and optional arguments -r (real run) and/or -s (silent)
while getopts srf: option
do
    case "${option}" in
        r) dryrun=0;;
        s) silent=1;;
        f) filename=${OPTARG};;
        *) 
            echo "usage: $0 [-r] [-s] [-f <filename>]" >&2
            exit 1
            ;;
    esac
done

echo;echo
if [ $silent == 1 ]; then
    h1 "Running Setup in silent mode"
    h2 "(auto reply default answer to all questions)"
else
    h1 "Running Setup in interactive mode..."
    if [ ! -t 0 ]; then
        echo " Interactive mode needs a terminal for STDIN! Exiting." >&2
        exit 1
    fi
fi

echo;echo
if [ $dryrun == 1 ]; then
    h1 "Running Setup in dryrun mode"
    h2 "(commands will not be run for real)"
else
    h1 "Running Setup in real mode..."
fi

echo;echo

############################################################################
# COMMANDS
############################################################################

# Run depending on dryrun
# $1 command
# $2 command info (optional)
runner() {
    case "$dryrun" in
        1) 
            echo " Dry run (fake): $2"
            echo "$1"
            echo
            ;;
        0) 
            echo " Running: $2"
            echo "$1"
            echo
            eval "$1"
            ;;
    esac
}


# Main ask function
# $1 question
# $2 default value
ask () {
    def="Yes"
    [[ $2 == false ]] && def="No"

    while true; do
        read -p " $1 " -n 1 -s -r;
        case ${REPLY:0:1} in
            "" )
                echo "Accepted default ($def)"
                answer="accept"
                ;;
            y|Y|1 )
                echo "Yes"
                answer=true
                ;;
            n|N|0 )
                echo "No"
                answer=false
                ;;
            q|Q|e|E )
                echo "Quit setup"
                exit 1;
                ;;
            * )
                echo "Skip"
                answer=""
                ;;
        esac
        break
    done
}

# defaults write
# $1 question
# $2 default answer
# $3 command
defaults_ask() {
    # Check the default exists by reading it
    # otherwise skip the whole setting question
    cv=$(defaults read $3 2>&1 | tail -n1)
    if [[ ! $cv =~ "does not exist" ]]; then
        # Silent, run auto
        if [[ $silent == 1 && $2 == false ]]; then
            runner "defaults write $3 -bool false" "$1"
        elif [[ $silent == 1 ]]; then
            runner "defaults write $3 -bool true" "$1"
        # Not silent, ask
        else
            # reformat current data
            echo;echo;
            CURRENT="No)"
            if [[ $cv == 1 || $cv == true ]]; then
                CURRENT="Yes)"
            fi

            ## Default true or default false
            if [[ $2 == false ]]; then
                ask "$1 ${options_def_false} ${current_intro} ${CURRENT}" "$2"
            else
                ask "$1 ${options_def_true} ${current_intro} ${CURRENT}" "$2"
            fi

            # Get value if user accepted default
            if [[ $answer == "accept" && $2 == false ]]; then
                answer=false
            elif [[ $answer == "accept" ]]; then
                answer=true
            fi

            # Run the answer through the dryrun check
            if [[ $answer == true || $answer == false ]]; then
                runner "defaults write $3 -bool $answer" "$1"
            fi
        fi
    fi
}

# Ask regular command
# $1 question
# $2 default answer
# $3 command if Yes
# $4 command if No (optional)
command_ask() {
    # Silent, run auto
    if [[ $silent == 1 && $2 == false ]]; then
        # if silent and default false, check we passed its command
        if [[ $4 != "" ]]; then
            runner "$4" "$1"
        fi
    elif [[ $silent == 1 ]]; then
        runner "$3" "$1"
    # Not silent, ask
    else
        echo;echo;
        # Default true or default false
        if [[ $2 == false ]]; then
            ask "$1 ${options_def_false}${options_end}" "$2"
        else
            ask "$1 ${options_def_true}${options_end}" "$2"
        fi

        # Get value if user accepted default
        if [[ $answer == "accept" && $2 == false ]]; then
            answer=false
        elif [[ $answer == "accept" ]]; then
            answer=true
        fi

        # Run the answer through the dryrun check
        if [[ $answer == true ]]; then
            runner "$3" "$1"
        elif [[ $answer == false && $4 != "" ]]; then
            runner "$4" "$1"
        fi
    fi
}

############################################################################
# BATCH PROCESSING
############################################################################

echo " Starting batch processing of data file..."
extension="${filename##*.}"
if [ ! -f "$filename" ]; then
    h2 "$filename is not a readable file, exit installation"
    exit 1
elif [[ ! $extension =~ "txt" && ! $extension =~ "csv" ]]; then
    h2 "$filename is not a txt nor csv file, exit installation"
    exit 1
fi

echo " Reading $filename"

############################################################################
# CSV PARSING
############################################################################

if [[ $extension == "csv" ]]; then
    loop_data_file() {
        (cp "$filename" ./tmp.csv) || sed '/^#/d' > ./tmp.csv
        IFS=$'\n' read -d '' -ra lines < ./tmp.csv ;
        rm ./tmp.csv
    }

    loop_data_file

    for line in "${lines[@]}"; do
        IFS=',' read -r what question defaultanswer commandYes commandNo <<< "$line"
        case "$what" in
            "#")
                h1 "$question"
                ;;
            "##")
                h2 "$question"
                ;;
            "d") 
                defaults_ask "$question" $defaultanswer "$commandYes"
                ;;
            "c")
                command_ask "$question" $defaultanswer "$commandYes" "$commandNo"
                ;;
            "b")
                command_ask "Install $question ?" true "brew install $question" "brew uninstall $question"
                ;;
            "k")
                command_ask "Install $question cask?" true "brew install --cask $question" "brew uninstall --cask $question"
                ;;
            "r")
                # Run a command without asking
                runner "$commandYes" "$question"
                ;;
        esac
    done
fi

############################################################################
# TXT PARSING
############################################################################

if [[ $extension == "txt" ]]; then
    value=$(<$filename)
    runner "$value"
fi


