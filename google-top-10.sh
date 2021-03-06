#!/bin/bash

# grank - find your google rank index
#
# 2008 - Mike Golvach - eggi@comcast.net
# updated 2013 - Mathieu jouhet - @daformat
#
# Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License
#

# Setup variables
results_per_page=10
base=0
num=1
start=0
multiple_search=0
not_found=0
found=0
output=0
# Default behavior is to stop at the first result page where url is found
search_all_results=0 # Set this to 1 to continue searching until 1000 first results.

# Text color variables
txtred=$(tput setaf 1) #  red
txtgrn=$(tput setaf 2) #  green
txtylw=$(tput setaf 3) #  yellow
txtprp=$(tput setaf 4) #  purple
txtpnk=$(tput setaf 5) #  pink
txtcyn=$(tput setaf 6) #  cyan
txtwht=$(tput setaf 7) #  white

# Text modifiers
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst=$(tput sgr0)     # Reset

#feedback
info="${txtbld}${txtcyn}[i]${txtrst}"
warn="${txtbld}${txtred}[!]${txtrst}"
ques="${txtbld}${txtylw}[?]${txtrst}"
ok="${txtbld}${txtgrn}[ok]${txtrst}"


# Wrong invocation
# Invocation without parameters
if [ $# -eq 0 ]
then
        echo "${txtbld}${txtylw}Usage: $0 URL Search_Term(s)${txtrst}"
        echo "URLs ${txtund}with${txtrst} http(s)://, ftp://, etc"
        exit 1
else
        search_terms=$@
fi

# Compute search query string
for x in $search_terms
do
        if [ $multiple_search -eq 0 ]
        then
                search_string=$x
                multiple_search=1
        else
                search_string="${search_string}+$x"
        fi
done

echo "${txtwht}Searching Google index${txtrst} for ${txtund}top 10 results${txtrst} for search query: ${txtund}$search_terms${txtrst}...${txtrst}"

num_results=`wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N|awk '{ if ( $0 ~ /.*bout .* results<\/div><div id="res">.*/ ) print $0 }'|awk -F"bout " '{print $2}'|awk -F" results" '{print $1}'`
echo "About $num_results results found in google index"
echo

while :;
do
        if [ $not_found -eq 1 ]
        then
                break
        fi
        echo "Searching $results_per_page results, starting at #$start"
        output=`wget -q --user-agent=Firefox -O - http://www.google.com/search?q=$search_string\&num=$results_per_page\&hl=en\&safe=off\&pwst=1\&start=$start\&sa=N|awk '{ gsub(/<h3 class/,"\n <h3 class"); print }'|sed 's/.*\(<h3 class="r">\)<a href=\"\([^\"]*\)\">/\n\2\n/g'|awk -v num=$num -v base=$base '{ if ( $1 ~ /http/ ) print base,num++,$0 }'|awk '{ if ( $2 < 10 ) print "# " $1 "0" $2 " for page: " $3; else if ( $2 == 100 ) print "# " $1+1 "00 for page: " $3;else print "# " $1 $2 " for page: " $3 }'|sed "s/#\(.*\)\( for page: \).*q=\(.*\)&amp;sa=.*/$txtgrn\1$txtrst \3/g"`

        if [ $? -ne 0 ]
        then
                echo "$warn An error occured"
        else
                echo "$output";
                break

        fi

done

echo
exit 0