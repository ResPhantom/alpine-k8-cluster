#!/bin/sh
a=2
b=7
if [ $a -ge $b ]
then
  echo "The variable 'a' is greater than the variable 'b'."
else
  echo "The variable 'b' is greater than the variable 'a'."
fi


# opt="$1";
# shift;

# echo  $@
# while [ $# -gt 0 ]
# do
#     opt="$1"
#     shift;
#     case "${opt}" in
#         "--ignore-preflight-errors" )
#            IGNORE_PREFLIGHT_ERRORS="--ignore-preflight-errors=all";;
#         "--hostname" )   
#            HOSTNAME="$1";shift; 
#            ;; 
#         "--cidr" )
#            CIDR="$1"; shift; 
#            ;;
#         *) echo "HELP" 
#    esac
# done


# for i in $(seq 5 -1 1)
# do 
#     echo "Updating Kernel. Rebooting in $i."
#     sleep 0.5
#     echo -e "${replace}Updating Kernel. Rebooting in $i.."
#     sleep 0.5
# done