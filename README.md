Paper Analysis
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


Examples
--------

![alt-text](https://raw.githubusercontent.com/drjs/paperanalysis/master/images/hpl_example.png "sample word cloud using one source")

![alt-text](https://raw.githubusercontent.com/drjs/paperanalysis/master/images/SEFI_Surface.png "sample Semantic Surface")


How The Package Works
----------------------

### Parsing Data Files

1. Get list of files to parse from user using GetFilesUI.
2. *MAP*: For each file get a list of words and count number of times a word occurs.
  1. PDF, doc and docx files are converted to txt files and stored in the temporary directory.
  2. The txt file is read in using TEXTSCAN, which converts the entire file to a cell array with one cell per word.
  3. The cell array is converted to the [CATEGORICAL](http://uk.mathworks.com/help/matlab/ref/categorical.html) data type. This automatically generates a list of the unique words in the cell array (the "categories"), and the [COUNTCATS](http://uk.mathworks.com/help/matlab/ref/countcats.html) function can then be used to quickly count the number of occurrences of each unique word.
  4. The categorical array is saved to mat file in the project directory. If you try to rescan the file again later, it will open the saved data instead.
3. *REDUCE*: Collate list of all words used across all files, and recalculate word counts for each paper based on new list.
  1. Now we have a set of categorical arrays containing all the words from all the files this is combined into one categorical `completeWordList`
  2. The categories from `completeWordList` are taken to get a complete list of ALL unique words used in the set of files. This is reordered so that the most common word comes at index 1 and the least common word at the `end` position.
  3. To  get each file's new word count we recategorise the saved data from the mapping phase to use the `completeWordList` categories instead. Then use the `COUNTCATS` function to get the word counts.

### Making a Word Cloud

Words are clustered by how commonly they occur together. The word size indicates how frequently the word is mentioned in total.
If only one file is provided in the project there will be no clustering because there are not enough separate files to compare word occurrences.

Clustering is calculated using MATLAB's [hierarchical clustering](http://www.mathworks.com/help/stats/hierarchical-clustering.html) algorithms from the Statistics and Machine Learning Toolbox:
* [linkage](http://www.mathworks.com/help/stats/linkage.html)
* [cluster](http://www.mathworks.com/help/stats/cluster.html)

The correlation between the words is used as a distance measure, so words that are perfectly positively correlated will have zero distance, and perfectly negatively correlated words have a very large distance.

The "linkage" clustering algorithm then:
1. steps through the words, and pairs words that are closest together (i.e. the words most postively correlated with each other).
2. The pairs can then be combined with other words or pairs which are close to each other.
3. The process of pairing words or pairs repeats until we have the number of groups required for the Word Cloud.
4. Each group of words is rendered as a cluster in the WordCloud.

This pairing tree is usually shown in a diagram called a dendrogram. It shows how words have been paired and the height of the link shows how close the two words being linked are.
    
This an example of a MATLAB [dendrogram](http://www.mathworks.com/help/stats/dendrogram.html) for some test files:

![alt-text](https://raw.githubusercontent.com/drjs/paperanalysis/master/images/SEFI_dendrogram.png "sample dendrogram")

This is the resulting WordCloud when separated into 8 clusters:

![alt-text](https://raw.githubusercontent.com/drjs/paperanalysis/master/images/SEFI_WordCloud.png "sample Word Cloud")



### Making a Semantic Surface
5. Display a semantic surface. The files are plotted as data points on a 3D scatter plot.


To start generating word clouds run GetFilesUI.

TODO
----

1. Improve read me project description. What does this do? why? how?
2. make example images
5. **Make parser use MATLAB's big data functionality for maximum efficiency.**
7. Make it possible to load a project from file?
8. delete unused files from repository


MATLAB Prerequisites
---------------------

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


Other Prerequisites
-------------------
To be able to read PDFs you need to install the free Xpdf utility from http://www.foolabs.com/xpdf/download.html

Reading doc or docx files is only possible on Windows operating systems, and requires Microsoft Word installed.
