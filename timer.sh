#!/run/current-system/sw/bin/bash
    

    # NOTE: -- replace the current shebang ( this one is for NIXOS )

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

## global vars
cols=$(tput cols)
version="1.1"
history_file="$HOME/config/bash_alarm/history"

## implement the pause/resume functionality
### implement helper functions

display_help() {
     help="$(cat << EOF
    ${BOLD} TIMER ${version}${NC}

    ${BOLD} Usage:${NC}
    $(basename "$0") -h [ hours ] -m [ minutes ] -s [ seconds ]

    ${BOLD} Required:${NC}
    at least one of the options need to be provided of integer type 
    -h hours
    -m minutes
    -s seconds

    ${BOLD} Additional optional args: ${NC}
    -t      text         tag to attach to the timer, define what you are working on 
    -f      file         filename where the audio is located      
    -e      text         action to take after the timer ends
    -c                   load from a configuration file
    -s                   load from the most recent state
    -l                   list the most recent timers
    -v                   display version

    ${BOLD} Controls: ${NC}
    ctrl + z            stop the timer but instance keeps runnning in the bg
    ctrl + c            resumes from the most recent state


    ${BLUE}If you find any bugs or issues, please report it to me\n${NC}
EOF
    )"
    printf "%b" "${help}";
}

## error
error_msg() {
    echo -e "${RED} Error: $1${NC}" >&2;
    exit 1;
}

## input
check_input() {
    local var=$1;
    local value=$2;

    if [[ -z "${var}"  ]]; then
        return 0;
    fi
        
    if [ "$value" =~ ^[0-9]+$  ]; then
        echo "the what or the so called end parameter needs to be a string" >&2;
        exit 1;
    fi
}

# format the time
format_time(){
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $secs;
}

# center the text in the terminal by adding some padding to the left of the text
center_text() {
    local text=$1;

    # finds the width of the terminal
    local width=$(stty size | cut -c 3-6);

    # the # gets the length of the text here
    local padding=$(( (width - ${#text}) /2 ));
    printf "%${padding}s%s\n" " " "${text}"; 
}

# we would want to save the history to some location
save_history() {
    mkdir -p "$(dirname "$history_file")";
    echo echo "$(date '+%Y-%m-%d %H:%M:%S') $hours $minutes $seconds \"$tag\" \"$ring\" \"$end\"" >> "$history_file"
}

init_timer() {
    command ...
}

display_progress() {
    command ...
}

pause_timer() {
    command ...
}
resume_timer() {
    command ...
}






while getopts ":h:m:s:t:" opt; do
    case $opt in
        h) hours=$OPTARG;;
        m) minutes=$OPTARG;;
        s) seconds=$OPTARG;;
        t) tag=$OPTARG;;
        u) ring=$OPTARG;;
        w) end=$OPTARG;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# check if at least one of the options is provided
check_options() {
if [[ -z $hours && -z $minutes && -z $seconds ]]; then
    echo -e "Usage:${RED} $0 -h [hours] -m [minutes] -s [seconds]"
    exit 1
fi
}

# set default values if not provided ( default is 0 )
default_options() {
    hours=${hours:-0}
    minutes=${minutes:-0}
    seconds=${seconds:-0}
}




# select music to play after the alarm ends
read -rp " Enter the location of the music or ring to be played after the work ends  "  ring
echo ""
echo ""

read -rp " Please something you want to work on   " tag
echo ""
echo ""

read -rp " What do you wanna do after the timer ends ?  " end
echo ""
echo ""


# Convert everything to seconds
total_seconds=$((hours * 3600 + minutes * 60 + seconds))

# total_time=$((hours * 3600 + minutes * 60 + seconds))
echo " Timer has started for $hours hours, $minutes minutes and $seconds seconds seconds with tag   ${tag}"
echo ""
echo ""


while [ $total_seconds -gt 0 ]; do

    # implement  progress bar 
    
    ## the actual percentage calculation is done here
    progress=$((100 - total_seconds * 100 / (hours * 3600 + minutes * 60 + seconds)))

    ## generate a seq of num join them with #
    ## remove all the digit leaving only the #
    ## remove all the empty spaces and divide by 2 as at 100% bar  will be 50 char wide
    echo -ne "${YELLOW}\r[$(seq -s '#' $((progress / 2)) | tr -d '[:digit:]')$(seq -s ' ' $(((100 - progress) / 2)) | tr -d '[:digit:]')] $progress% ${NC}"

   sleep 1

    # sleep for 1 second then decrement the time in seconds
    ((total_seconds--))
done

echo ""
echo ""

# array of stuffs to do after the timer ends

arr=("smoke" "chess" "code\ more" "shorts" "reels")

quotes=("Is this the best yoy've got ??" "If you are the artist of your own life then why no create a better picture of yourself" "Do everything they said you cant" "Discipline or regret ?")

poe_len=${#quotes[*]};
rnd_idx=$((RANDOM % poe_len));

message="The timer has finished!  "
pos=$(( (cols - ${#message}) /2 ))
printf "%${pos}s%s\n" " " "$message"

else
    if [[ "${arr[*]}" =~ $end ]]; then
echo ""
echo ""
        printf "${GREEN}%${pos}s%s\n" " " " A quote or something "

echo ""
echo ""
        printf "${RED} %${pos}s%s\n" " " "${quotes[rnd_idx]}"
    fi
fi

while true; do 
        paplay "${ring}";
    # TODO: -- replace the path with the alarm's tone frowith your own path
    notify-send -u normal "Bash alarm" "The timer is up, Please make a new timer to keep going";
    break
sleep 1
done

# TODO: 1>    Create multiple instances of the alarm
# TODO: 2>    Calender suppport
# TODO: 3>    Error handiling , loggings and debuggings
# TODO: 4>   Volume control and audio selections

display_help
check_options
default_options
check_input
