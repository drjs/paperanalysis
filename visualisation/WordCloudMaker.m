function WordCloudMaker
% cla reset
clear variables
% clear classes

load realtestdata

% textHandles = generateTextHandles(words, wordCount, corrMat, tree);
% T = cluster(tree, 'maxclust', numberClusters);
% c = hist(T, numberClusters)


f = figure('Name', 'Word Cloud', 'Position', [340 340 1000 620]);

wordarray = generateTextHandles(words, wordCount, corrMat, clusterTree);

axis manual
nwords =30;
w = WordCluster(wordarray(1), 0.5, 0.5);
randcorr = rand(1,nwords-1); %corrMat(1,2:nwords)
w = w.addWords(wordarray(2:nwords), randcorr); %, wordCount(2:8), corrMat(1, 2:8));]); %


ax = gca;
ax.Visible = 'off';
f.Color = 'black';


end

