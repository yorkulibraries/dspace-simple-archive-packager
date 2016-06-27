# Batch Ingest

## Install the [Dspace Simple Archive Packager](https://github.com/mxbees/dspace-simple-archive-packager).

A script hosted on [Github][git] has replaced [our old workflow for doing batch ingests][old]. To use the script, you don't necessarily need a github account, however, you'll require one if you want contribute changes to the script.

1.  In your terminal, check to ensure that you have git installed. Or, if you're on windows, make sure you've [installed the client][win].
2. Create a github account for yourself if you don't already have one.
3. Fork [the YorkU Libraries repo][yorkudspace]. 
2.  Clone the forked repo locally by using this command (which will install both the repo and the submodule): <pre>git clone —recursive https://github.com/[your username here]/dspace-simple-archive-packager.git</pre>
3.  Once you enter the directory, you'll note that there is a directory called xlsx2csv.

## Usage

A typical call to the script will look like this:

    ./dspace-simple-archive-packager.sh -d [delimiter] -o [path/to/objects/] -s [filetype] foo.xlsx

Explanation:

The script takes three mandatory flags:

1.  -d, is to set the delimiter for the resulting CSV. You should pick a character that is not contained within any field, otherwise, the parsing will be wrong.
2.  -o, is the directory of the objects/item you want to ingest/upload into DSpace.
3.  -s, is for the suffix of the objects without the period (eg. 'pdf' 'jpg' but not '.jpg' or '.pdf').

The argument the script takes is the metadata for the objects as an XLSX spreadsheet.

All these elements are necessary for a successful execution of the script.

**Depending on your system, you may or may not need to adjust [the python command on line 65](https://github.com/mxbees/dspace-simple-archive-packager/blob/master/dspace-simple-archive-packager.sh#L65) to include 'sudo'. In my local environment I need this to run python scripts but not on our server.**

## Testing the ingest.

How to do testing (un/mounting data store)

You can now mount/umount the assetstore on yorkspace-dev with the following commands:

    sudo mount /dspace/assetstore  
    sudo umount /dspace/assetstore

Unmount the assetstore if you need to test deposit. Remount it when you're done testing.

# Tweaking the script according to metadata requirements.

## Creating a new branch

The best way to make small tweaks to the script based on different metadata needs is to create a new branch in the cloned git repo:

    git checkout -b [branch name]
    
For example: `git checkout -b etd` to create a branch for tweaking the script for ETD requirements. [Refer to this documentation to learn more about branches in git][branches]. Be sure to check what branches already exist, `git branch` (this will give you a list and the asterisk denotes which branch you are currently working on).

**Note: Even if you are working to update or change the main script (ie, the master branch), you should create a temporary branch to work on and merge this into the master branch after you've completed testing the changes.**

## Contributing changes to York's github repo.

As you've been working on the script, you've hopefully been committing changes as you make them (or frequently enough that each commit has only incremental changes). 

Once you're finished working on your branch and everything is committed, don't forget to push the branch to your remote (ie, github) repo. 

Checkout from that branch, `git checkout master` and be sure to commit and push any changes. The end result should be that the repo on github is a perfect mirror of your local repo. 

Got onto github and [follow these directions to make a pull request][pull]. This will notify one of the repo owners to review the changes and decide whether or not to merge them into the institution's repo. 

# Why xlsx2csv

My initial hope was that I could write something that would just allow us to use the regular 'save as... csv' option in Excel or LibreOffice. But this proved impossible.

The major stumbling block? Newlines. The nature of the type of data we can have is that someone's abstract might contain newlines. When you use a GUI tool to export to csv, these newlines are not escaped. Which essentially ruins your ability to work with the resulting csv on the commandline, which processes text files line by line. Except that an abstract field with new lines might actually occupy 3 lines.

And bash only tools are rather limited in their ability to manipulate CSVs. I'm sure that converting from xlsx to csv using bash tools is possible, but its beyond my current skill level.

xlsx2csv was the only tool I was able to find that escaped and preserved newlines, so that when the csv is converted to xml, the escaped newlines can be expanded again, to ensure that the metadata looks the way it ought to.

I'd love it if someone were to point me in the direction (either by tutorial or help with the code) of doing this wholly within bash to remove the python dependency.

[git]: https://github.com

[old]: https://github.com/yorkulibraries/dspacescripts

[win]: https://git-scm.com/download/win

[branches]: https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell

[yorkudspace]: https://github.com/yorkulibraries/dspace-simple-archive-packager

[pull]: https://help.github.com/articles/using-pull-requests/
