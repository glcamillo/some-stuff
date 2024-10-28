#!/bin/bash -x
#
#  Encoding UTF-8
#  Last revision: 2024-10-28

# test-links-with-curl.sh: the purpose is read URLs and
#   test them by using CURL tool (https://curl.se/).
#   The test consists in a HTTP HEAD method.
#
# Obs.:
# 1. Change the Host argument in the file: test-links-config-for-curl.txt
# 2. For now, it is for links in the same web server (domain).


PROG_NAME="$(basename "$0")"
FILENAME_INPUT=""
FILENAME_OUTPUT=""
URL=""


# https://curl.se/docs/manpage.html
# --head is equivalent to -X HEAD
# --header "Host: 
# --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
# --header "Accept-Language: en-US,en;q=0.5,*/*"
# --compressed
# --user-agent "Mozilla/5.0 (X11; Linux x86_64; rv:58.0) Gecko/20100101 Firefox/58.0""
# --silent
# --no-progress-meter
# --verbose

# The above parameters for curl are in the config file.
CURL_CONFIG=test-links-config-for-curl.txt

############################################################
#     Usage                                               #
#  fi: file that contains URLs
#      lines starting with # are comments and ignored
#  fo: filename for output, and contains:
#      LINK and HTTP STATUS+HEADER from response
#  -u: optional argument: if provided a url, then the
#      script will not read file input
############################################################
usage()  {
    # echo "$PROG_NAME: usage: $PROG_NAME -fi [--file_input] FILE_CONTAINING_LINKS -fo [--file_ouput] FILE_OUTPUT  [-u | --url URL]"
    echo "$PROG_NAME: usage: $PROG_NAME -fi FILE_CONTAINING_LINKS -fo FILE_OUTPUT_RESPONSES  [-u | --url URL]"
    exit 0
}

CURL_CMD=$(which curl)
if [[ -z $CURL_CMD ]]; then
    echo "\n --- ERROR: curl command not found --- \n "
    exit 1
fi

############################################################
#     Read line arguments
#     Two mandatory: -fi and -fo; or -fo and -url
############################################################
i=0
while [[ -n "$1" ]]; do
    case "$1" in
        -fi | --file_in)  shift
                          FILENAME_INPUT=$1
                          i=$((i + 1))
                          ;;
        -fo | --file_out) shift
                          FILENAME_OUTPUT=$1
                          i=$((i + 1))
                          ;;
        -u | --url)       shift
                          URL=$1
                          i=$((i + 1))
                          ;;
        -h | --help)      usage
                          exit
                          ;;
        *)                usage >&2
                          exit 1
                          ;;
    esac
    shift
done

# Test the arguments.
if [[ $i -lt 2 ]]; then
    usage >&2
    exit 1
elif [[ -z $FILENAME_OUTPUT ]]; then
    echo -e "\n --- ERROR: output file (-fo) is mandatory ---\n"
    exit 1
fi

############################################################
#    Some utility functions.
############################################################

testing_input_file() {
    if [[ -n "$1" ]] && [[ -f "$1" ]]; then
        return 0
    else 
        return 1
    fi
}


testing_output_file() {
    if [[ -n "$1" ]] && [[ -f "$1" ]]; then # String not null and File exists
        echo " --- ERROR: output file exists. Type a new one. ---\n"
        return 1
    fi
    if touch "$1" && [[ -f $1 ]]; then
        return 0
    else
        echo " --- ERROR creating the output file. ---\n"
        return 1
    fi
}

testing_input_file $FILENAME_INPUT
RETURN_VALUE=$?
if [[ $RETURN_VALUE -ne 0 ]]; then
    echo -e "\n --- ERROR: check the input file. ---\n"
    exit 1
fi

testing_output_file $FILENAME_OUTPUT
RETURN_VALUE=$?
if [[ $RETURN_VALUE -ne 0 ]]; then
    # echo -e "\n --- ERROR: check the input file. ---\n"
    exit 1
fi

############################################################
#    Function for testing the links.
#    Results written to output file.
############################################################
testing() {
    FILENAME_INPUT=$1 
    FILENAME_OUTPUT=$2

    # If provided URL from command line, then
    #   we will not read the input file for LINKS
    if [[ -n $3 ]]; then
        echo "$3" >> $FILENAME_OUTPUT
        $CURL_CMD --head -K $CURL_CONFIG $3 >> $FILENAME_OUTPUT
        return 0
    fi

    while read -r LINK; do
        echo $LINK
        [[ $LINK = \#* ]] && continue
        # ISO 8601 format and returns UTC time
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "$LINK - $TIMESTAMP" >> $FILENAME_OUTPUT
        $CURL_CMD --head -K $CURL_CONFIG $LINK >> $FILENAME_OUTPUT
        echo "" >> $FILENAME_OUTPUT
        # Sleeps for a random number of seconds (1 to 30s)
        sleep $((1 + RANDOM % 30))
    done < $FILENAME_INPUT
}



testing $FILENAME_INPUT $FILENAME_OUTPUT $URL 


