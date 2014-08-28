paperanalysis
=============

Analyze conference papers in MATLAB


Visualisation
-------------

To visualise the SEFI conference data run the `WordCloudMaker` [script](./visualisation/WordCloudMaker.m).

To customise the WordCloud settings so that it looks how you want, edit the Constant properties in [WordCloud.m](./visualisation/WordCloud.m).
These are:

1. **prettyFonts**. A cell array of fonts to use for the words. Fonts are randomly selected from this list.
2. **backgroundColour**. The colour to make the figure background. This can be a 1x3 RGB vector or a standard colour string e.g. `'black'` or `'k'`.
3. **fontScaleFactor**. Scale factor controlling the size the fonts are displayed. Adjust this to make the words bigger or smaller.
4. **satelliteClusterDistanceScaleFactor**. Controls how far the outer word clusters are from the central cluster. If the words are too close together or far apart, adjust this value. The distance is proportional to how correlated the two clusters are.

### Visualisation TODO

1. Finish [generateRandomWordCloud.m](./visualisation/generateRandomWordCloud.m).
2. improve word cloud creation to work without correlation matrix
3. improve word cloud creation to work without groups (puts all words into one cluster).
4. remove all usage of the statistics toolbox. Or replace with alternatives using random numbers. Word clouds should be possible without it.
5. add helpful title/author tooltips to datamining scatter3 plot.
6. add "Made with MATLAB" logo.

    

