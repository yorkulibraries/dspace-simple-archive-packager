##About

This is a script I'm writing to port our current workflow to a better bash solution (consolidating code, etc.). Ideally, this script should be able to replace everything in this repository:

[https://github.com/yorkulibraries/dspacescripts](https://github.com/yorkulibraries/dspacescripts)

The function of this script is to do the create [Dspace Simple Archives](https://wiki.duraspace.org/display/DSDOC18/Importing+and+Exporting+Items+via+Simple+Archive+Format) in order to do batch uploading. So the output of the script is many directories with the following files: the object for upload, the contents file, and a valid dublin_core.xml.

##Installation

Clone the repo to wherever you want it to live (this will also install the submodule):

    `git clone --recursive https://github.com/yorkulibraries/dspace-simple-archive-packager.git`
    
##Usage

A typical call to the script will look like this:

`./dspace-simple-archive-packager.sh -d [delimiter] -o [path/to/objects/] -s [filetype] foo.xlsx`

Explanation:

The script takes three mandatory flags:

1. -d, is to set the delimiter for the resulting CSV. You should pick a character that is *not* contained within any field, otherwise, the parsing will be wrong.
2. -o, is the directory of the objects/item you want to ingest/upload into DSpace.
3. -s, is for the suffix of the objects *without the period* (eg. 'pdf' 'jpg' but not '.jpg' or '.pdf'). 

The argument the script takes is the metadata for the objects as an XLSX spreadsheet. 

All these elements are necessary for a successful execution of the script.

##Why xlsx2csv

My initial hope was that I could write something that would just allow us to use the regular 'save as... csv' option in Excel or LibreOffice. But this proved impossible.

The major stumbling block? Newlines. The nature of the type of data we can have is that someone's abstract might contain newlines. When you use a GUI tool to export to csv, these newlines are not escaped. Which essentially ruins your ability to work with the resulting csv on the commandline, which processes text files line by line. Except that an abstract field with new lines might actually occupy 3 lines.

And bash only tools are rather limited in their ability to manipulate CSVs. I'm sure that converting from xlsx to csv using bash tools is possible, but its beyond my current skill level.

xlsx2csv was the only tool I was able to find that escaped and preserved newlines, so that when the csv is converted to xml, the escaped newlines can be expanded again, to ensure that the metadata looks the way it ought to.

I'd love it if someone were to point me in the direction (either by tutorial or help with the code) of doing this wholly within bash to remove the python dependency.

##One note of warning...

Depending on your system, you may or may not need to adjust the python command to include 'sudo'. In my local environment I need this to run python scripts but not on our server. 

Something to keep in mind.
