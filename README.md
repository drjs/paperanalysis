paperanalysis
=============

Analyse conference papers in MATLAB, visualise similarities between papers in MATLAB.

* what does this do?
* what is a semantic surface?
* what is the word cloud


Usage
-----

To get started, run the function `GetFilesUI`. This will open up the user interface
for selecting the files to read. From there you can create word clouds or 
a semantic surface visualising how related the files are based on word analysis.


How The Package Works
----------------------

1. Get list of files to parse from user using GetFilesUI.
2. For each file get a list of words and count number of times a word occurs (MAP)
3. Collate list of all words used across all files, and recalculate word counts for each paper based on new list (REDUCE)
4. Displays a word cloud. 
  * Word clusters indicate words that occured frequently together across different papers. 
  * Word size indicates how often the word occurs
  * Font is random
5. Display a semantic surface. The files are plotted as data points on a 3D scatter plot.


To start generating word clouds run GetFilesUI.

### TODO

1. Improve read me project description. What does this do? why? how?
2. make example images
5. **Make parser use MATLAB's big data functionality for maximum efficiency.**
7. Make it possible to load a project from file?
8. delete unused files from repository

Prerequisites
-------------
To be able to read PDFs you need to install the free Xpdf utility from http://www.foolabs.com/xpdf/download.html

Reading doc or docx files is only possible on Windows operating systems, and requires Microsoft Word installed.

### MATLAB Prerequisites

#### MATLAB R2014b or higher.
This relies on the updated MATLAB graphics system which was introduced in R2014b.
Earlier versions of MATLAB will not be able to reliably run this code.

#### Statistics Toolbox (optional)
This toolbox is used to do the statistical analysis, comparing files with each other.
The code should work without the statistics toolbox installed, however you 
can only create word clouds (without clusters) and not the Semantic Surface.

#### Parallel Computing Toolbox (optional)
If you have a very large number of files to read this toolbox can parallelise
the scanning of files and data collection. The code will run without this toolbox
although it might be slower.

#### Curve Fitting Toolbox (optional)
For the semantic surface plot, having this toolbox will allow MATLAB to generate
a surface of best fit. Otherwise only a scatter plot is shown.

Examples
--------

![alt-text](https://raw.githubusercontent.com/drjs/paperanalysis/master/images/75WordsCloudBlack.png "sample word cloud")
