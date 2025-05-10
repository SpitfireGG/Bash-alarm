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
config_file="$HOME/.config/bash_alarm/config/"
history_file="$HOME/config/bash_alarm/history/"
pause_time=""
last_milestone=0

## implement the pause/resume functionality
### implement helper functions

## display the help section
display_help() {
    help="$(
        cat <<EOF
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
    printf "%b" "${help}"
}

## print error message
error_msg() {
    echo -e "${RED} Error: $1${NC}" >&2
    exit 1
}

## format time
format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $secs
}

# center the text in the terminal by adding some padding to the left of the text
center_text() {
    local text=$1

    # finds the width of the terminal
    local width
    width=$(stty size | cut -c 3-6)

    # the # gets the length of the text here
    local padding=$(((width - ${#text}) / 2))
    printf "%${padding}s%s\n" " " "${text}"
}

# we would want to save the history to some location
save_history() {
    mkdir -p "$(dirname "$history_file")"
    echo echo "$(date '+%Y-%m-%d %H:%M:%S') $hours $minutes $seconds \"$tag\" \"$ring\" \"$end\"" >>"$history_file"
    echo ""
    echo "saved to file"
}

check_milestone() {

    local percent=$1
    local milestones=(25 50 75)

    for milestone in "${milestones[@]}"; do

        if [ "$percent" -ge "$milestone" ] && [ "$last_milestone" -lt "$milestone" ]; then
            if command -v notify-send &>/dev/null; then
                notify-send "timer progress" "$milestone% complete for task: $tag"
            fi
            last_milestone=$milestone
            break
        fi

    done
}

show_history() {

    command ...

}

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

config_load() {
    if [ -f "$config" ]; then
        source "$config_file"
    else
        set_default_ring="/usr/share/sounds/freedesktop/stereo/complete.oga"
        default_end="take a break"
    fi
}

display_progress() {
    local width=$1
    local percent=$2
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    printf "["
    if [ $filled -gt 0 ]; then
        printf "%${filled}s" | tr ' ' '#'
    fi
    if [ $empty -gt 0 ]; then
        printf "%${empty}s" | tr ' ' '-'
    fi
    printf "]"
}

pause_timer() {
    if [ -z "$pause_time" ]; then
        pause_time=$(date +%s)
        echo -e "\n${YELLOW} timer paused, to resume press CTRL + z${NC}"
    else
        resume_timer
    fi
}

resume_timer() {
    if [ -n "$pause_time" ]; then
        local current_time
        current_time=$(date +%s)
        local pause_duration=$((current_time - pause_time))
        start_time=$((start_time + pause_duration))
        unset pause_time
        echo -e "\n${GREEN} timer resumed${NC}"
    fi
}

init_timer() {

    hours=${hours:-0}
    minutes=${minutes:-0}
    seconds=${seconds:-0}
    ring=${ring:-$set_default_ring}
    end=${end:-$default_end}

    # convert everything to seconds
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))

    # check if the time duration is equal or smaller than 0
    if [ $total_seconds -le 0 ]; then
        echo "timer duration must be greater than 0"
    fi

    start_time=$(date +%s)
    original_seconds=$total_seconds
}

run_timer() {

    # display  the timer information

    clear
    echo -e "${BOLD}${BLUE}timer${NC}"
    echo -e "${CYAN}task:${NC} $tag"
    echo -e "${CYAN}duration:${NC} $(format_time $total_seconds)"
    echo -e "${CYAN}end action:${NC} $end"
    echo ""

    tput civis # to hide cursor

    while [ $total_seconds -gt 0 ]; do
        #
        # skip updates if timer is paused
        if [ -n "$pause_time" ]; then
            sleep 1
            continue
        fi

        # calculate progress
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local adjusted_total=$((original_seconds - elapsed))

        # ensure we dont go negative seconds
        if [ $adjusted_total -lt 0 ]; then
            adjusted_total=0
        fi

        total_seconds=$adjusted_total
        local progress=$((100 - (total_seconds * 100 / original_seconds)))

        # calculate optimal bar width based on terminal size
        local bar_width=$((cols > 80 ? 50 : cols / 2 - 10))

        # format times
        local elapsed_formatted=$(format_time $elapsed)
        local remaining_formatted=$(format_time $total_seconds)

        # check for milestones
        check_milestone $progress

        # display progress
        echo -ne "\r${YELLOW}$(display_progress $bar_width $progress) ${BOLD}${progress}%${NC}"
        echo -ne " | ${GREEN}elapsed: ${elapsed_formatted}${NC} | ${RED}remaining: ${remaining_formatted}${NC}  "

        sleep 1

        # exit if total_seconds reached 0
        if [ $total_seconds -le 0 ]; then
            break
        fi
    done

    echo ""
    tput cnorm # show cursor
}

play_alarm() {

    # display completion message
    echo ""
    center_text "╔══════════════════════════════════════╗"
    center_text "║          timer complete!             ║"
    center_text "╚══════════════════════════════════════╝"
    echo ""
    echo ""
    center_text "task: $tag"
    echo ""

    # play sound
    if [ -f "$ring" ]; then
        if command -v paplay &>/dev/null; then
            paplay "$ring" &
        elif command -v aplay &>/dev/null; then
            aplay "$ring" &
        elif command -v afplay &>/dev/null; then
            afplay "$ring" &
        else
            echo -e "${YELLOW}warning: no audio player found. cannot play sound.${NC}"
        fi
    else
        echo -e "${YELLOW}warning: sound file not found: $ring${NC}"
    fi

    # send notification
    if command -v notify-send &>/dev/null; then
        notify-send -u critical "timer complete" "task: $tag is finished!"
    fi

    # check for action
    if [ -n "$end" ]; then
        echo -e "${GREEN}next action: $end${NC}"
    fi

    if [ -f "$STATE_FILE" ]; then
        rm "$STATE_FILE"
    fi
}

main() {

    trap pause_timer SIGTSTP                 # ctrl+z
    trap resume_timer SIGCONT                # resume after ctrl+z
    trap 'save_state; exit 0' SIGINT SIGTERM # ctrl+c

    # parse command line arguments
    hours=0
    minutes=0
    seconds=0
    tag=""
    ring=""
    end=""

    while getopts ":h:m:s:t:" opt; do
        case $opt in
        h) hours=$OPTARG ;;
        m) minutes=$OPTARG ;;
        s) seconds=$OPTARG ;;
        t) tag=$OPTARG ;;
        u) ring=$OPTARG ;;
        w) end=$OPTARG ;;
        \?) display_help ;;
        esac
    done

    config_load

    if [[ $hours -eq 0 && $minutes -eq 0 && $seconds -eq 0 && "$use_config" != "true" && ! -f "$STATE_FILE" ]]; then
        read -rp "enter hours (0-99): " hours
        read -rp "enter minutes (0-59): " minutes
        read -rp "enter seconds (0-59): " seconds
        read -rp "enter task description: " tag
        read -rp "enter sound file path (or leave empty for default): " ring
        read -rp "enter end action (or leave empty for default): " end
    fi

    init_timer

    save_history

    run_timer

    play_alarm
}
main "$@"
