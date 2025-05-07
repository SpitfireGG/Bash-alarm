#!/run/current-system/sw/bin/bash

    # NOTE: -- replace the current shebang ( this one is for NIXOS )

RED='\033[0;31m'
# GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cols=$(tput cols)

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
if [[ -z $hours && -z $minutes && -z $seconds ]]; then
    echo -e "Usage:${RED} $0 -h [hours] -m [minutes] -s [seconds]"
    exit 1
fi

# set default values if not provided ( default is 0 )
hours=${hours:-0}
minutes=${minutes:-0}
seconds=${seconds:-0}

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
    progress=$((100 - total_seconds * 100 / (hours * 3600 + minutes * 60 + seconds)))

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

if [[ "$end" =~ ^[0-9]+$ || "$end" =~ ^[-][0-9]+$  ]]; then
    echo "the what or the so called end parameter needs to be a string";
    exit 1;
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

