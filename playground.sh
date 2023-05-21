#!/bin/bash
opt="$1";
shift;
ary=("$@")
echo ${ary}
echo ${#ary[@]}
echo ${ary[1]}

for i in ${#ary[@]}
do
    case "${ary[$i]}" in
        "--ignore-preflight-errors" )
           IGNORE_PREFLIGHT_ERRORS="--ignore-preflight-errors=all";;
        "--hostname" )   
           HOSTNAME="${ary[$i+1]}";;
        "--cidr" )
           CIDR="${ary[$i+1]}";;
        *) echo "HELP"
   esac
done

# for i in $(seq 5 -1 1)
# do 
#     echo "Updating Kernel. Rebooting in $i."
#     sleep 0.5
#     echo -e "${replace}Updating Kernel. Rebooting in $i.."
#     sleep 0.5
# done