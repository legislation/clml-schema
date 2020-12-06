# Batch Validation Tool
Developed by colin@mackenziesolutions.co.uk for TNA (based on some existing code)

## Introduction
The purpose of this XProc 1.0 tool and associated XSLT2 files is to provide a bulk/batch validation tool capable of:
- validating the entire legalisation contents (or any folder subset) against the XSD schema
- creating an XML error file for each file that has a schema error (with both the original error text and a cleaned form that is easier to count for reporting) 
- where the error files can be analysed by xQuery or combined into a single XML error file by XSLT
- where the merged error file can be summarised into an XML report (with counts per error type and a list of files sorted by number of errors per file)

**Note:** The tool is intended to be used for development and testing purposes. It is not a production tool and it relies on the data files being accessible as part of a folder path and not stored in a database. A variation of this tool could be developed to be run on a single file as part of the production process.

**Note:** The tool currently validates against an XSD schema. The tool could be further developed to validate against other schema types or perform additional validation using Schematron.

**Note: ** If the tool proves to run successfully for TSO and TNA users with all files being processed in one batch,
 it would be possible to enhance the tool to automatically run the merge and report steps after the validation step.

**Requirements:** A recent version of Oxygen Developer like v21.0 (this includes Java, Saxon and Calabash) or recent versions of 64 bit Java, Saxon (version 9+) and Calabash (I am using xmlcalabash-1.1.24-98.jar)

## 1. Batch Validation
The first step is to run the batch validator on the required XML files. This step can be run on all files at once or folder subsets of files (e.g. revised then enacted) if the processor does not have sufficent memeory to process them all at once.

The validation XProc `validate-folder.xpl` can be run from Oxygen or from a batch file (or script).

The sample batch file provided is called `validateFolder.bat`.
This file needs to be edited in order to
* set the environment path variables (for Calabash, Saxon and Java) to appropriate values
* set the memory Xmx parameter to alot sufficient memory (e.g. -Xmx6G). **Note:** 64 bit Java should be used to support this amount of memory 
* set the XProc parameter `xml-input-folder` to the folder path of the folder that contains the XML files to be processed (e.g. file:/C:/data27-02-2020/revised)
* optionally set the schema location using the `schemaUri` parameter (or change the default inside your copy of `validate-folder.xpl`).
* optionally set the folder location for the error logs using the `logFolder` parameter (or change the default inside your copy of `validate-folder.xpl`).

optionally set the schema location using the `schemaUri` parameter (or change the default inside your copy of `validate-folder.xpl`).

If you are using an Oxygen you can create an XProc transformation to set the parameters (in the `Options` tab).
**Note:** the `source` port on the `inputs` tab should be empty.

**Warning:** Processing the entire legalisation data could take a long time (6-12 hours) depending on the speed of processor, amount of memory available and the disk speed.
The script can be left running unattended overnight.
Processing this many files over a network drive would be VERY slow and is NOT recommended.

**Warning: ** if you have old error files in the output folder then you should either delete them before running the script again or specify a different folder.
Otherwise old error log files may be left on the disk even though the file now validates.

When the script is running there will initially be a delay (could be a few minutes) while the script creates a list of all the files to process by recursively examining the folders and sub-folders for ".xml" files.

The script will then out put a message for each file processed indicating if it is valid or not (these could be captured from the bat file by adding '>> trace.txt' but there should be no need to do so.

If the script finds a file that has a schema validation error then a file with the same name as the XML input file will be created in the specified logs folder. This file does NOT contain the original source, instead it contains details of the error (an XSLT (`cleanLog.xsl`) is run automatically to clean up the error message and provide structures making it easier to report on the error).

These files can be used in later stages and/or used to find specific example sources of specific errors.

**Note:** This version of the Calabash XProc processor currently tries to throw an error with the schema on valid files (I have reported this). The XPorc script detects this false positive and an error log is NOT created in this circumstance (but the trace message says "... is valid (Xproc error ignored)").

The script will also create a .log file  (named after the date and time the script started) that includes information on how long the script took to run and a count of how many files were checked.

## 2. Merging the Error Files

While it is possible to use xQuery to analyse these individual error files created in the previous step, the typical next step is to merge the error files into a single file.

The merge can be done by running the `mergeAndCleanLogs.xsl` from an Oxygen XSLT2 configuration scenario (or via a bat file or XProc script running Saxon if required).

This XSLT is run on itself (it has no single XML file input) and has one parameter that needs to be set `gpInputPath` to specify the folder to which the merged error file is written.

The merged error file will be named after the date and time (YYYMMDDHHMMSS.xml) and will contain all of the error information from the individual error files plus the totals from all the log files (or log file if the validation was run in one batch).

This process can typically take a number of minutes (but not hours).

**Note:** There is an additional parameter in the `cleanLog.xsl` file (that is used by `mergeAndCleanLogs.xsl`) that should only be used during development.
If the developer adjusts the "cleaning" logic but does not want to rerun the full validation step, the developer can set the parameter `gpForceReClean` to 'true' and this will attempt to apply that logic when the merge is run.
Normally this is set to false as the clean is done as part of the batch validation step and it slows down the merge.

## 3. Creating the Summary Report
To create a summary report of the errors the XSLT `analyseLog.xsl` can be run (from Oxygen or from a bat file etc.).

The information in this report can help prioritise what issues or content XML files should be fixed to make the largest impact.

The source XML for the XSLT is the merged file created in the previous step.

You do not have to set any parameters although there is one optional parameter `mode`.

The `mode` parameter can be set to 'groupErrors' that outputs group of the same errors type across files mode 'fileErrors' will produce a list of files sorted by number of errors otherwise it does both modes by default.

The XSLT will produce a file to stdout that can be viewed and/or saved.

On the top-level "report" element there are a number of attributes describing the files processed.

These include:
* totalFiles - the total number of files processed in the batches
* totalInvalidFiles - the number of files that do not validate against the schema
* a number of attributes ending in "-1" or "-2" (the number indicates the batch they came from) indicating the source XML folder used and the start and end time of the batch validation.

There are two child elements of the top-level "report" element:
* "errorsByErrorType" this contains a list of each type of error (sorted by the total number per type). There are attributes showing the number of different errors and the total occurrence of all errors.

   each child element "error" has text describing the error (with specific values removed to enable counting of the same error) and a count attribute showing the total number of errors of this type.

* "errorsByFile" this contains a list of each file that has an error (sorted by the total number of errors per file). There are attributes showing the number of files with errors and the total number of all errors.
*  The "percentageValidFiles" attribute shows the calculated percentage validity (of valid files versus total processed)

   each child element "error" has the path (relative to the script folder if the logs folder is a sub-folder of it) and the name of the source fil and a count attribute showing the total number of errors in this file.

**As this is a summary report, it cannot show which file has which specific error.
This can be done easily by searching in the merge file for a specific error).**

**Note:** While the cleaning and grouping process attempts to avoid multiple reports of the same error, this cannot be achieved in all cases. A large number will still be knock-on errors (fix in one place and does not error elsewhere) where the knock-on errors are not easily cleaned out of the statistics. 
