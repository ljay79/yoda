#
# Copyright (c) 2012    Jens Rosemeier / CiD
#                       (http://www.jens79.de)
#
# Based on "read_ini.sh" from:
# Copyright (c) 2009    Kevin Porter / Advanced Web Construction Ltd
#                       (http://coding.tinternet.info, http://webutils.co.uk)
# Copyright (c) 2010, 2011    Ruediger Meier <sweet_f_a@gmx.de>
#                             (https://github.com/rudimeier/)

declare -a PROJECTS=()

containsElement()
{
    for e in "${@:2}"
    do
        if [ "$e" = "$1" ] ; then
            return 1
        fi
    done
    return 0
}

function read_projects()
{
    function check_ini_file()
    {
        if [ ! -r "$INI_FILE" ] ; then
            echo "read_projects: '${INI_FILE}' doesn't exist or not" \
                "readable" >&2
            return 1
        fi
    }

    # enable some optional shell behavior (shopt)
    function pollute_bash()
    {
        if ! shopt -q extglob ;then
            SWITCH_SHOPT="${SWITCH_SHOPT} extglob"
        fi
        if ! shopt -q nocasematch ;then
            SWITCH_SHOPT="${SWITCH_SHOPT} nocasematch"
        fi
        shopt -q -s ${SWITCH_SHOPT}
    }

    # unset all local functions and restore shopt settings before returning
    # from read_ini()
    function cleanup_bash()
    {
        shopt -q -u ${SWITCH_SHOPT}
        unset -f check_prefix check_ini_file pollute_bash cleanup_bash
    }

    local INI_FILE=""
    local INI_SECTION=""

    # {{{ START Deal with command line args

    # Set defaults
    local CLEAN_ENV=0

    # {{{ START Options


    while [ $# -gt 0 ]
    do
        case $1 in
            * )
                if [ -z "$INI_FILE" ]
                then
                    INI_FILE=$1
                else
                    if [ -z "$INI_SECTION" ]
                    then
                        INI_SECTION=$1
                    fi
                fi
            ;;
        esac

        shift
    done

    if [ -z "$INI_FILE" ] && [ "${CLEAN_ENV}" = 0 ] ;then
        echo -e "Usage: read_projects FILE"\
            "[SECTION]\n  or   read_projects" >&2
        cleanup_bash
        return 1
    fi

    if [ -z "$INI_FILE" ] ;then
        cleanup_bash
        return 0
    fi

    if ! check_ini_file ;then
        cleanup_bash
        return 1
    fi

    # }}} END Options

    # }}} END Deal with command line args

    local LINE_NUM=0

    # IFS is used in "read" and we want to switch it within the loop
    local IFS=$' \t\n'
    local IFS_OLD="${IFS}"

    # we need some optional shell behavior (shopt) but want to restore
    # current settings before returning
    local SWITCH_SHOPT=""
    pollute_bash

    while read -r line
    do
#echo line = "$line"

        ((LINE_NUM++))

        # Skip blank lines and comments
        if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
        then
            continue
        fi

        # Project block?
        if [[ "${line}" =~ ^\[[a-zA-Z0-9_:]{1,}\]$ ]]
        then
            # remove Project tags [ ]
            pline="${line##\[}"
            pline="${pline%%\]}"
            # Parse Project name and attributes
            IFS=":"
            read -r PNAME PMODE PCATEGORY <<< "${pline}"
            IFS="${IFS_OLD}"

#           echo "PNAME:${PNAME}; PMODE:${PMODE}; PCATEGORY:${PCATEGORY}"

            # add Project to PROJECTS array if not yet in
            containsElement "$PNAME" "${PROJECTS[@]}"
            if [ $? -eq 0 ]; then
                PROJECTS[${#PROJECTS[*]}]="${PNAME}"
            fi

            varname="${PNAME}_modes"
            eval "modes=(\${"${varname}"[@]})"
            containsElement "${PMODE}" "${modes[@]}"
            if [ $? -eq 0 ]; then
                varname="${PNAME}_modes[\${#${PNAME}_modes[*]}]"
                val="${PMODE}"
                eval "$varname=$val"
            fi

            if [ ! "${PCATEGORY}" = "" ]; then
                varname="${PNAME}${PMODE}_categories"
                eval "cats=(\${"${varname}"[@]})"
                containsElement "${PCATEGORY}" "${cats[@]}"
                if [ $? -eq 0 ]; then
                    varname="${PNAME}${PMODE}_categories[\${#${PNAME}${PMODE}_categories[*]}]"
                    val="${PCATEGORY}"
                    eval "$varname=$val"
                fi
            fi

#           echo "modes: ${auctions_modes[@]}"
#           echo "cats1: ${auctionsproduction_categories[@]}"
#           echo "cats2: ${auctionsstage_categories[@]}"

            continue
        fi


        # Valid var/value line? (check for variable name and then '=')
        if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
        then
            echo "Error: Invalid line:" >&2
            echo " ${LINE_NUM}: $line" >&2
            cleanup_bash
            return 1
        fi


        # split line at "=" sign
        IFS="="
        read -r VAR VAL <<< "${line}"
        IFS="${IFS_OLD}"

        # delete spaces around the equal sign (using extglob)
        VAR="${VAR%%+([[:space:]])}"
        VAL="${VAL##+([[:space:]])}"
        VAR=$(echo $VAR)

        # Construct variable name:
        # full stops ('.') are replaced with underscores ('_')
        VARNAME=${PNAME}__${PMODE}__${PCATEGORY}__${VAR//./_}

        if [[ "${VAL}" =~ ^\".*\"$  ]]
        then
            # remove existing double quotes
            VAL="${VAL##\"}"
            VAL="${VAL%%\"}"
        elif [[ "${VAL}" =~ ^\'.*\'$  ]]
        then
            # remove existing single quotes
            VAL="${VAL##\'}"
            VAL="${VAL%%\'}"
        fi

        # enclose the value in single quotes and escape any
        # single quotes and backslashes that may be in the value
        VAL="${VAL//\\/\\\\}"

        # check if varname is "harvest" we use this as an array with multiple definitions
        if [ "${VAR}" = "harvest" ]; then
            VARNAME=$VARNAME"[\${#"$VARNAME"[*]}]"
        fi

        VAL="\$'${VAL//\'/\'}'"

        eval "$VARNAME=$VAL"

    done  <"${INI_FILE}"

#    echo "----------------------------------------------------"
#    echo "Projects: ${PROJECTS[@]}"
#    echo "modes: ${auctions_modes[@]}"
#    echo "cats1: ${auctionsproduction_categories[@]}"
#    echo "cats2: ${auctionsstage_categories[@]}"
#    echo "harvest: ${auctions__production__eu__harvest[@]}"

    cleanup_bash
}
