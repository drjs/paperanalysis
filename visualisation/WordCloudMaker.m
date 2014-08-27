function WordCloudMaker
% cla reset
clear variables
% clear classes

load testdata

% textHandles = generateTextHandles(words, wordCount, corrMat, tree);
% T = cluster(tree, 'maxclust', numberClusters);
% c = hist(T, numberClusters)


f = figure('Name', 'Word Cloud', 'Position', [50 50 1000 620]);
gr = cluster(clusterTree, 'maxclust', 8);

cloud = WordCloud(words, wordCount, corrMat, gr);

axis manual
% nwords = 30;
% w = WordCluster(wordarray(1), 0.5, 0.5);
% randcorr = rand(1,nwords-1); %corrMat(1,2:nwords)
% w = w.addWords(wordarray(2:end), randcorr); %, wordCount(2:8), corrMat(1, 2:8));]); %
% w.recalculateLimits()

ax = gca;
ax.Visible = 'off';
f.Color = 'black';



end

