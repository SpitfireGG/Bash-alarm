#!/run/current-system/sw/bin/bash

    # FIXME: -- replace the current shebang ( this one is for NIXOS ) with your's

RED='\033[0;31m'
# GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'


cols=$(tput cols)


while getopts ":h:m:s:t:" opt; do
    case $opt in
        h) hours=$OPTARG ;;
        m) minutes=$OPTARG ;;
        s) seconds=$OPTARG ;;
        t) tag=$OPTARG ;;
        w) end=$OPTARG ;;
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

# Check if at least one option is provided
if [[ -z $hours && -z $minutes && -z $seconds ]]; then
    echo -e "Usage:${RED} $0 -h [hours] -m [minutes] -s [seconds]"
    exit 1
fi

# Set default values if not provided
hours=${hours:-0}
minutes=${minutes:-0}
seconds=${seconds:-0}
read -rp " please soemthing you want to work on  " tag
echo ""
echo ""


read -rp " what do you wanna do after the timer ends ?  " end
echo ""
echo ""

# Convert everything to seconds
total_seconds=$((hours * 3600 + minutes * 60 + seconds))



# total_time=$((hours * 3600 + minutes * 60 + seconds))
echo " Timer has started for $hours hours, $minutes minutes and $seconds seconds seconds with tag   ${tag}"
echo ""
echo ""




while [ $total_seconds -gt 0 ]; do

    # Calculate progress percentage
    progress=$((100 - total_seconds * 100 / (hours * 3600 + minutes * 60 + seconds)))

    echo -ne "${YELLOW}\r[$(seq -s '#' $((progress / 2)) | tr -d '[:digit:]')$(seq -s ' ' $(((100 - progress) / 2)) | tr -d '[:digit:]')] $progress% ${NC}"

   sleep 1

    ((total_seconds--))
done

echo ""
echo ""


#array of stuffs to do after the timer ends;
arr=("smoke" "chess" "code\ more" "shorts" "reels")

poets=("Is this the best yoy've got ??" "if you are the artist of your own life then why no create a better picture of yourself" "Do everything they said you cant" "Discipline or regret ?")
poe_len=${#poets[*]};
rnd_idx=$((RANDOM % poe_len));


#adjust the 
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
        
        printf "${GREEN}%${pos}s%s\n" " " " A poet for the badass motherfucker !!! "

echo ""
echo ""
        printf "${RED} %${pos}s%s\n" " " "${poets[rnd_idx]}"
    fi
fi

while true; do 

    paplay /home/kenzo/Audios/i_need_you.mp3

    # TODO: -- replace the path with the alarm's tone frowith your own path

    notify-send -u normal "Bash alarm" "the alarm has finished"

    break
sleep 1

done


# TODO: 1>    Create multiple instances of the alarm
# TODO: 2>    Calender suppport
# TODO: 3>    Error handiling , loggings and debuggings
# TODO: 4>   Volume control and audio selections

