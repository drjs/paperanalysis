function cloud = generateWordCloud(parserObject, nwords)
%GENERATEWORDCLOUD When provided with a set of word counts generated with the
%ParseFiles object this will generate a word cloud representing that information.

% numWords = size(parserObject.wordCounts, 1);
% numDocs  = size(parserObject.wordCounts, 2);

keywords = parserObject.uniqueWords(1:nwords);
wordCounts = parserObject.wordCounts(1:nwords, :);
wordCounts = sum(wordCounts, 2);
normalisedWordCounts = parserObject.normalisedWordCounts(1:nwords, :);
correlationMatrix = corr(normalisedWordCounts', 'type', 'Pearson');

nclusts = 3;

% generate cluster tree
tree = linkage(correlationMatrix, 'average');
clusterGroups = cluster(tree, 'maxclust', nclusts);

settings = WordCloud.WordCloudFactory();
cloud = WordCloud.WordCloud(keywords, wordCounts, correlationMatrix, clusterGroups, settings);
cloud.recolourWithinClusters(settings.colourMap);
end

