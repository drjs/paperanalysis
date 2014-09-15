%% SEFI Conference Word Cloud Generator
% This script will generate a word cloud of the keywords from the
% <http://www.birmingham.ac.uk/facilities/mds-cpd/conferences/sefi-2014/index-new.aspx SEFI 2014>
% conference in Birmingham.
% Words are clustered by how commonly they occur together. 
% The word size indicates how freqently the word is mentioned in the
% conference proceedings.
%%

%% Correlating The Words
% The clustering is based on a measure of how well correlated the words are
% with each other. The process for measuring the clustering is:
% 
% # Parse all paper abstracts for dictionary of unique conference keywords 
% (3633 keywords), and their total count across all paper abstracts.
% # For most frequent N words, it counts how many times each keyword was used in each abstract.
% # This gives a normalised histogram of keyword occurences for each abstract.
% # From that histogram, MATLAB calculates the correlation coefficient between all N words, 
% and we get an NxN matrix of correlation coefficients.

clear variables
load sefiData

%% Forming the Clusters
% Clustering is calculated using inbuilt <http://www.mathworks.com/help/stats/hierarchical-clustering.html hierarchical clustering> 
% algorithms <http://www.mathworks.com/help/stats/linkage.html linkage> and
% <http://www.mathworks.com/help/stats/cluster.html cluster> from MATLAB statistics toolbox.
% 
% # Correlation is used as a distance measure between the words, so
% words that are perfectly positively correlated will have zero distance, and
% perfectly negatively correlated words have a large distance.
% # The algorithms works through word list, and pairs words that are
% closest together.
% # The pairs can then be combined with other words or pairs which are
% close to each other.
% # the process repeats until all words are grouped together into a tree.
% # This pairing is ususally shown in a diagram called a dendrogram. It
% shows how words have been paired and the height of the link shows how
% close the two words being linked are.
% 
% This is the <http://www.mathworks.com/help/stats/dendrogram.html dendrogram> for the SEFI conference data:

if license('test', 'statistics_toolbox')
    nclusts = 9;
    % generate cluster tree
    tree = linkage(correlationMatrix, 'average');
    % split tree into nclusts distinct clusters
    clusterGroups = cluster(tree, 'maxclust', nclusts);
    % uncomment if you want to see a dendrogram of the data:
    [~, ~, displayOrder] = dendrogram(tree);
    set(gca, 'XTickLabel', words(displayOrder), 'XTickLabelRotation', 90);
    %take a picture of the dendrogram for the publised report.
    snapnow;
end

%% How are Clusters Displayed as Word Clouds?
% The word cloud script manually sets the cloud to display nine clusters.
% So the clustering algorithm is stopped once there are nine groups of words.
% 
% *Formatting:*
% 
% In the word cloud, each sub-cloud cluster has its own colour and the
% words are grouped together spatially.
% Word font is randomly selected, and the word size is proportional to its
% total count across all conference papers.
% 
% *Each word cluster is formed by the following process:*
% 
% * The word with the highest word count goes in the centre.
% 
% * Remaining words in the cluster are sorted by how correlated they are to
% the central word.
% 
% * Going from most correlated to least correlated, the words are added to
% the cluster in a spiral from the centre. This means the words most
% correlated to the central word are closer to the centre of the cluster,
% and the words around the outside are least correlated.
% 
% *For the whole cloud:*
% 
% The cluster with highest total word count (across all words
% in the cluster) goes in the centre of the figure.
% Remaining clusters are places evenly around the edge. Their distance
% from the centre is proportional to the mean correlation between the words
% in the satellite cluster and the central cluster.

rng('shuffle');
cloud = WordCloud(words, wordFreq, correlationMatrix, clusterGroups);

addMWLogo;

set(gcf, 'papertype', 'A0', 'renderer', 'painters', 'paperpositionmode', 'auto', 'InvertHardcopy', 'off');
% print -dpng -r600 -noui 75WordsCloud

