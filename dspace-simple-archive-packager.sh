#!/bin/bash
#This script takes a commandline argument, essentially 
#the xlsx file that you're working with.

#For setting the options on the Commandline. Running the 
#script without these options will break it, since the 
#options set variables used throughout the script. 
#Chose to do it this way because it allows for some
#flexibility when running the script. You can change the 
#delimiter, directory of objects, and filetypes depending
#on what you are doing. Also not wrapped in a function
#because the variables are used in other functions.
while getopts :d:o:s:h opt; do
  case $opt in
    d)
        delimiter=$OPTARG
        ;;
    o)
        objects=$OPTARG
        object_path=$(echo $objects | sed 's/\/$//g')
        ;;
    s)
        suffix=$OPTARG
        ;;
    h)
        echo "
  The flags for this script are all required for it to    
  function correctly.
        
  Flags:
    -d  # Set the delimiter for the CSV output, ensure
        # that the delimiter is not in any field.
    -o  # Path to the directory of objects.
        # The trailing slash is not required
        # Example: path/to/directory
    -s  # For the suffix of the objects.
        # Examples: 'pdf' 'jpg'
            
    -h  # Bring up this help text" 1>&2
        exit 1
        ;;
    \?)
        echo "
  Invalid option: -$OPTARG
  Use -h for help." 1>&2
        exit 1
        ;;
    :)
        echo "
  Option -$OPTARG requires an argument.
  Use -h for help." 1>&2
        exit 1
        ;;
  esac
done
shift $((OPTIND -1))

#calling the python module that converts the xlsx file 
#to a csv. depending on your data, you might have to 
#change the delimiter. You want one that is *not* 
#contained in any of the fields, otherwise your data 
#will be parsed in strange ways later on.
file_name=$( basename $1 .xlsx )
csv="$file_name.csv"
sudo python xlsx2csv/xlsx2csv.py -e -d $delimiter $1 /tmp/$csv

#the function to make packages
make_simple_archive_format_package () {
#looks in the directory of objects you have and 
#iterates over them
for i in $object_path/*$suffix
do
    id=$(basename $i .$suffix)
    #creates each package directory
    mkdir $object_path/record.$id
    #copies the objects into the package
    cp $i $object_path/record.$id
    #this creates the required 'contents' files 
    #as specified in the DSpace Simple Archival Format
    echo $id.$suffix > $object_path/record.$id/contents
done 
}

#creates the start of the dublin core record.
make_dc_header () {
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > $object_path/record.$dc_identifier/dublin_core.xml
echo "<dublin_core>" >> $object_path/record.$dc_identifier/dublin_core.xml
}

#creates the closing tag
make_dc_footer () {
echo "</dublin_core>" >> $object_path/record.$dc_identifier/dublin_core.xml
}

#Function to populate the dublin_core.xml needed 
#for the upload package. 
make_dc_body () {
#this is just to reset the field seperator to 
#the default 
OLDIFS=$IFS
IFS="$delimiter"
c1=2
#grabs the headers of the csv file and the second 
#command reads it into an array.
header_row=$(head -n1 /tmp/$csv | sed "s/dc\.identifier\.none@//")
read -a all_headers x <<< "$header_row"
#creates a temporary csv with no headers
sed 1,2d /tmp/$csv > /tmp/no_headers.csv
#starts counter for cut
#calls the header function
make_dc_header
#loop to iterate over the header array
for header in "${all_headers[@]}"; do
    #setting up our variables for each xml line. 
    #The field variable searches for the identifier, 
    #grabs the associated record, and splits it into 
    #distinct fields.
    field=$(grep "$dc_identifier" /tmp/$csv | cut -d"$delimiter" -f $c1)
    esc_field=$(escape_char "$field")
    #these following two take the headers and use the
    #structure to fill in the attributes for the 
    #<dcvalue> tag.
    element=$(echo "$header" | sed 's/dc\.//g' | cut -d'.' -f1)
    qualifier=$(echo "$header" | sed 's/dc\.//g' | cut -d'.' -f2)
    #this writes the tag. The 'printf '%b\n'' is what 
    #allows us to restore the newlines in the xml 
    #(since csv doesn't handle them gracefully.
    printf '%b\n' "<dcvalue element=\"$element\" qualifier=\"$qualifier\">$esc_field</dcvalue>" >> $object_path/record.$dc_identifier/dublin_core.xml
    c1=$((c1+1))
done
#calls the footer to close the xml record.
make_dc_footer
IFS=$OLDIFS
}

#this is for making all the records
make_dc_record () {

#loop to iterate over all the objects in the directory
for i in $object_path/*$suffix
do    
    #grabs the identifier need in the make_dc_body 
    #function.
    dc_identifier=$( basename $i .$suffix )
    make_dc_body
    c1=1
done
}

escape_char () {
  echo "$1" | sed 's/&/\&amp;/g' | sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/"/\&quot;/g' | sed "s/'/\&apos;/g"
}

#call all the functions to do all the things.
make_simple_archive_format_package
make_dc_record
#clean_ampersands
