% clear all
% clear classes
numberClusters = 4;

load realtestdata

textHandles = generateTextHandles(words, wordCount, corrMat, tree);
T = cluster(tree, 'maxclust', numberClusters);
c = hist(T, numberClusters)
w = WordCluster(textHandles(1));
corrMat(1, 2:8)
w.add7Words(textHandles(2:8)); %, wordCount(2:8), corrMat(1, 2:8));

