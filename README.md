paperanalysis
=============

Analyze conference papers in MATLAB


How The Package Works
----------------------

1. Get list of files to parse from user using GetFilesUI.
2. For each file get a list of words and count number of times a word occurs (MAP)
3. Collate list of unique words across all papers, and recalculate word counts for each paper based on new list (REDUCE)
4. Displays a word cloud. 
  * Word clusters indicate words that occured frequently together across different papers. 
  * Word size indicates how often the word occurs
  * Words are coloured by cluster
  * Font is random
5. Adjust word cloud so that it displays nicely and save cloud to image or to mat file.


Prerequisites
-------------
To be able to read PDFs you need to install the free Xpdf utility from (http://www.foolabs.com/xpdf/download.html).


Visualisation
-------------

To visualise the SEFI conference data run the `GenerateSEFIWordCloud` [script](./visualisation/GenerateSEFIWordCloud.m).

[visualisation/GenerateSEFIWordCloud.pdf](./visualisation/GenerateSEFIWordCloud.pdf) contains a short description of how the Word Cloud clustering and visualisation is performed.

Example word cloud:
![alt-text](https://raw.githubusercontent.com/drjs/paperanalysis/master/visualisation/75WordsCloudBlack.png "sample word cloud")

### Customisation

To customise the WordCloud settings so that it looks how you want, edit the Constant properties in [WordCloud.m](./visualisation/WordCloud.m).
These are:

1. **prettyFonts**. A cell array of fonts to use for the words. Fonts are randomly selected from this list.
2. **backgroundColour**. The colour to make the figure background. This can be a 1x3 RGB vector or a standard colour string e.g. `'black'` or `'k'`.
3. **fontScaleFactor**. Scale factor controlling the size the fonts are displayed. Adjust this to make the words bigger or smaller.
4. **satelliteClusterDistanceScaleFactor**. Controls how far the outer word clusters are from the central cluster. If the words are too close together or far apart, adjust this value. The distance is proportional to how correlated the two clusters are.

### Visualisation TODO

1. Optimise word clouds for [generateRandomWordCloud.m](./visualisation/generateRandomWordCloud.m).
2. Create GUI for interactive customisation of Word Cloud
3. Change GetFilesUI to not take manual paths, instead use editbox to get project title. This will allow the project to save parsed project data and/or cloud settings with a project name.
4. Write parser.
5. Make parser use MATLAB's big data functionality for maximum efficiency.
6. Add warning about needing to install pdftotext
    

