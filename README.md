paperanalysis
=============

Analyse conference papers in MATLAB, visualise similarities between papers in MATLAB.


How The Package Works
----------------------

1. Get list of files to parse from user using GetFilesUI.
2. For each file get a list of words and count number of times a word occurs (MAP)
3. Collate list of unique words across all papers, and recalculate word counts for each paper based on new list (REDUCE)
4. Displays a word cloud. 
  * Word clusters indicate words that occured frequently together across different papers. 
  * Word size indicates how often the word occurs
  * Font is random
5. Adjust word cloud so that it displays nicely and save cloud to image or to mat file.

To start generating word clouds run GetFilesUI.

Prerequisites
-------------
To be able to read PDFs you need to install the free Xpdf utility from http://www.foolabs.com/xpdf/download.html

Reading doc or docx files is only possible on Windows operating systems, and requires Microsoft Word installed.



### Visualisation TODO

5. Make parser use MATLAB's big data functionality for maximum efficiency.
7. Make it possible to load a project from file?
