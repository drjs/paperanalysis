function WordCloudMaker
% cla reset
clear variables
% clear classes

load sefiData

% T = cluster(tree, 'maxclust', numberClusters);
% c = hist(T, numberClusters)


% f = figure('Name', 'Word Cloud', 'Position', [50 50 1000 620]);
f = figure('Name', 'Word Cloud', 'Units','normalized','OuterPosition',[0 0 1 1]);
axis manual

ax = gca;
ax.Visible = 'off';
f.Color = 'black';

gr = cluster(clusterTree, 'maxclust', 8);
cloud = WordCloud(words, wordCount, corrMat, gr);
% cloud.boxEachCluster();

% testCluster()


end

function testCluster()
load realtestdata
nwords = 9;

textHandles = generateTextHandles(words, wordCount, corrMat, clusterTree);
arrayfun(@(h) set(h,'Visible','off'), textHandles((nwords+1):end));
% textHandles((nwords+1):end).Visible = 'off';

w = WordCluster(textHandles(1), 0.5, 0.5);
line([w.right, w.right], ylim, 'color', 'g');
randcorr = rand(1,nwords-1); %
w = w.addWords(textHandles(2:nwords), corrMat(1,2:nwords)); %, wordCount(2:8), corrMat(1, 2:8));]); %
line([w.right, w.right], ylim, 'color', 'b');
w = w.recalculateLimits();
line([w.right, w.right], ylim, 'color', 'r');
end

function makeRect(clust, col)
r = rectangle('position', [clust.left, clust.bottom, clust.right-clust.left, clust.top-clust.bottom], 'edgecolor', col);
end

