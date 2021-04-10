#!/bin/bash
# (C) Christian Kluenter
# Github: https://github.com/Lecatron


## This short script is used to do a screenshot on each URL in the given file.
## Additional to this, it takes these Screenshot to write a HTML-Report to support for review and comparison.

usage="
Usage: $0

Options:
    -h      Displays help / usage
    -d      Checks and installs all dependencies
            Dependecies:
              - cutycapt
              - md5sum
    -t      Only takes Screenshots
"



## Declare Variables:
reportname="web-report-compare2.html"       # Defines the name of the Report.
folder="./Screenshots2/"                    # Defines the folder for storage of the Screenshots.
domains="./subdomains.txt"                  # Defines the file, in which all the domains are listed.
total=$(wc -l $domains | cut -d " " -f1)    # Calculates the total amount of Domains.
hashlist="hashlist.txt"                     # Defines the Name of the Hashlist file.
hashlistfolder="./hashes"

## Clear Screen
clear


######  Function Definition ######

taking_screenshots() {
    mkdir -p $folder
    i=1
    echo -e "Starting to take Screenshots..."
    echo -e "$total Websites needs to be collected.\n"
    echo -e "Starting the collection..."
    for domain in $(cat $domains); do
      
        #printf "Taking Screenshot of: $domain\r"
        echo -ne "Progress:    $i/$total\r"
       
        cutycapt --url=https://$domain --out=$folder$domain.png.https.png
        cutycapt --url=http://$domain --out=$folder$domain.png

        i=$((++i))
    done
    echo -e "Screenshot are taken.\n\n"
}


write_report () {
    printf "Now creating report..."

    echo "<HTML><body><br>" > $reportname
    echo '<table style="width:100%" border="1">' >> $reportname
        
    for domain in $(cat $domains); do
        echo "<tr>" >> $reportname
        echo '<td>' $domain'.https.png<BR> <IMG SRC="'$folder$domain'.png.https.png" width=600></td>' >> $reportname
        echo '<td>' $domain '<BR> <IMG SRC="'$folder$domain'.png" width=600></td>' >> $reportname
        echo "</tr>" >> $reportname
       
    done
    echo "</table>" >> $reportname
    echo "</body></html>" >> $reportname

    echo "Report created!"
}


create_hashlist () {
    mkdir -p $hashlistfolder
    echo "Creating hashlist..."
    echo -n "" > $hashlist
    for file in $folder*; do
        printf "$(md5sum $file)\n" >> $hashlistfolder$hashlist
    done
    cat $hashlist | sed -e 's/\s\+/,/g' > $hashlistfolder/modified_hsh-list.txt
    cat modified_hsh-list.txt | sort > $hashlistfolder/sorted_hashlist.txt
    echo "done"
}



###### Use of Options ######

## Run FULL Functionality
if [ -z $1 ]
then
    taking_screenshots
    write_report
    create_hashlist
    exit 1
fi


## Only take Screenshots
if [ $1 == "-t" ]
then
    taking_screenshots
    exit 1
fi


## Check for Dependencies
if [ $1 == "-d" ]
then
    sudo apt install cutycapt md5sum
    exit 1
fi


## Show Usage and Options
if [ $1 == "-h" ]
then
    echo -e "$usage"
    exit 1
fi