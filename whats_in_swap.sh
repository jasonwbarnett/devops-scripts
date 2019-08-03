#!/bin/bash
# Get current swap usage for all running processes
# Original script by: Erik Ljungstrom 27/05/2011
#                     http://northernmost.org/blog/find-out-what-is-using-your-swap/

function help {
cat<<EOF
$(basename "$0") OPTIONS...

Options are :

-z :: Include ALL processes in swap, even if currently using 0 bytes.
-h :: output this help.
-x :: set debug mode.


=======
Example
=======
$(basename "$0") -z

EOF
}

while getopts ":zhx" opt; do
  case $opt in
    z)  ZERO=true ;;
    h)  help; exit 0 ;;
    x)  set -x ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        help
        exit 1 ;;
  esac
done
shift $((OPTIND-1))


SUM=0
OVERALL=0

for DIR in $(find /proc/ -maxdepth 1 -type d | grep -E "^/proc/[0-9]+");do
  PID=$(echo "${DIR}" | cut -d / -f 3)
    PROGNAME=$(ps -p "${PID}" -o comm --no-headers)

    while IFS= read -r SUM; do
       (( SUM = SUM + SWAP ))
    done < <(grep Swap "${DIR}/smaps" 2> /dev/null | awk '{ print $2 }')

    if [[ $SUM -gt 0 ]] && [[ -n $PROGNAME ]];then
        echo "PID=$PID - Swap used: $SUM - ($PROGNAME)"
    elif [[ $SUM == 0 ]] && [[ $ZERO == true ]] && [[ -n $PROGNAME ]];then
        echo "PID=$PID - Swap used: $SUM - ($PROGNAME)"
    fi

    (( OVERALL = OVERALL + SUM ))
    SUM=0
done

echo -e "\nOverall swap used: $OVERALL\n"
