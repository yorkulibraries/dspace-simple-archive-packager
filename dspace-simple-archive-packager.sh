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

ys_license () {
  echo "YORKSPACE NON-EXCLUSIVE DISTRIBUTION LICENSE

By signing and submitting this license, you (the author(s) or copyright owner) grants to York University the non-exclusive right to reproduce, translate (as defined below), and/or distribute your submission (including the abstract) worldwide in print and electronic format and in any medium, including but not limited to audio or video.

YorkSpace and your use of YorkSpace is governed by the terms and conditions of the York University website posted at: http://www.yorku.ca/web/about_yorku/privacy.html

You agree that York University may, without changing the content, translate the submission to any medium or format for the purpose of preservation.

You also agree that York University may keep more than one copy of this submission for purposes of security, back-up and preservation.

You represent that the submission is your original work, and that you have the right to grant the rights contained in this license. You also represent that your submission does not, to the best of your knowledge, infringe upon anyone's copyright.

If the submission contains material for which you do not hold copyright, you represent that you have obtained the unrestricted permission of the copyright owner to grant York University the rights required by this license, and that such third-party owned material is clearly identified and acknowledged within the text or content of the submission.

IF THE SUBMISSION IS BASED UPON WORK THAT HAS BEEN SPONSORED OR SUPPORTED BY AN AGENCY OR ORGANIZATION OTHER THAN YORK UNIVERSITY, YOU REPRESENT THAT YOU HAVE FULFILLED ANY RIGHT OF REVIEW OR OTHER OBLIGATIONS REQUIRED BY SUCH CONTRACT OR AGREEMENT.

York University will clearly identify your name(s) as the author(s) or owner(s) of the submission, and will not make any alteration, other than as allowed by this license, to your submission."
}

etd_license () {
  echo "Non-Exclusive License to York University

In the interests of facilitating research and contributing to scholarship at York University (“York”) and elsewhere, the author (“Author”) hereby grants to York a non-exclusive, royalty free and irrevocable license on the following terms:

- York is permitted to reproduce, copy, store, archive, distribute, translate, publish and loan  to the public the Author’s thesis or dissertation, including the abstract and metadata  (“the Work”), in whole or in part, anywhere in the world, for non-commercial purposes, in any format and in any medium.  Distribution may be in any form, including, but not limited to, the right to transmit or publish the Work through the Internet or any other telecommunications device; to digitize, photocopy and microfiche the Work; or through library, interlibrary and public loans.  York is permitted to sub-license or assign any of the rights mentioned in this agreement to third party agents to act on York's behalf.

- York may keep more than one copy of the Work and convert the Work from its original format into any medium or format for the purposes of security, back-up, and preservation or to facilitate the exercise of York’s rights under this license.

- York may collect cost-recovery fees for reproducing or otherwise making the Work available.

- The Author confirms that the Work is the approved and final version, in whole and without alteration, submitted to the Faculty of Graduate Studies, York University, as a requirement of the York degree program. 

- The Author confirms that the Work is their original work, that they have the right and authority to grant the rights set out in this license and that the Work does not infringe copyright or other intellectual property rights of any other person or institution.  If the Work contains material to which the Author does not hold copyright it is clearly identified and acknowledged. Copyright–protected material not in the public domain is included either under the "fair dealing" provisions of the Copyright Act (Canada) or the Author has obtained and retained copies of written permission from the copyright holder(s) to include the material and to grant to York the rights set out in this license.

- York will clearly identify the Author as the copyright holder of the Work and will not make any alteration, other than as allowed by this license, to the Work. All copies of the Work will include a statement to the effect that the copy is being made available in this form by authority of the Author and copyright owner solely for the purpose of private study and research and may not be copied, further distributed or altered for any purpose, except as permitted by copyright law, without written authority from the Author.

- A nonexclusive license in no way limits the Author as the copyright holder in making other nonexclusive uses of the Work. The Author otherwise retains all rights in the Work subject to the nonexclusive grants and conditions of this license and accordingly holds sole responsibility for complying with copyright and other legal requirements.

- The Author agrees that York is not responsible for any misuse of the Work by third parties who access the Work through YorkSpace, York's Institutional Repository.

- I have reviewed and agree to accept the conditions and regulations of the Faculty of Graduate Studies as outlined in the Thesis and Dissertation Handbook."
}

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
    ys_license > $object_path/record.$id/license.txt
    echo -e "license.txt\tbundle:LICENSE" >> $object_path/record.$id/contents
    etd_license > $object_path/record.$id/YorkU_ETDlicense.txt
    echo -e "YorkU_ETDlicense.txt\tbundle:LICENSE" >> $object_path/record.$id/contents
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
header_row=$(head -n1 /tmp/$csv | sed "s/dc\.identifier\.none$delimiter//")
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
    if [ ${#esc_field} -gt '0' ]
    then
      printf '%b\n' "<dcvalue element=\"$element\" qualifier=\"$qualifier\">$esc_field</dcvalue>" >> $object_path/record.$dc_identifier/dublin_core.xml
    fi
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
