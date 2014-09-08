function cloud = WordCloudMaker
% cla reset
clear variables
% clear classes

load sefiData

nclusts = 10;
tree = linkage(correlationMatrix, 'average');
clusterGroups = cluster(tree, 'maxclust', nclusts);
% c = hist(clusterGroups, nclusts)
cloud = WordCloud(words, wordFreq, correlationMatrix, clusterGroups);
cloud.rescaleText(2.5)
% cloud.rescaleClusterSeparation(0.2);

addMWLogo;

set(gcf, 'papertype', 'A0', 'renderer', 'painters', 'paperpositionmode', 'auto');
print -dpng -r500 75WordsCloud

end