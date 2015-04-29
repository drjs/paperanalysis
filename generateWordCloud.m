function cloud = generateWordCloud(keywords, wordCounts)
%GENERATEWORDCLOUD When provided with a set of word counts generated with the
%ParseFiles object this will generate a word cloud representing that information.

% === Pantelis code ===

numWords = size(wordCounts, 1);
numDocs  = size(wordCounts, 2);

% TF-IDF normalization (Term Frequency. * Inverse Docum. Frequency)
FreqCounts = bsxfun(@rdivide, wordCounts, sum(wordCounts));
TF = log( FreqCounts + 1);
IDF = log( numDocs ./ (  sum( ~(wordCounts' <2*eps) ) + 1) );
WordFreq_tfidf = TF .* repmat(IDF',1, numDocs);

% L2 Normalization
DocFreqNorms = cellfun(@norm, num2cell(WordFreq_tfidf,1));
DocFreq =  WordFreq_tfidf./repmat(DocFreqNorms,[numWords 1]);
correlationMatrix = corr(DocFreq', 'type', 'Pearson');

% === end Pantelis code ===

% use only the most frequent 100 words
nwords = 100; 
nclusts = 3;

keywords = keywords(1:nwords);
wordCounts = wordCounts(1:nwords, :);
wordCounts = sum(wordCounts, 2);
correlationMatrix = correlationMatrix(1:nwords, 1:nwords);

% generate cluster tree
tree = linkage(correlationMatrix, 'average');
% uncomment if you want to see a dendrogram of the data:
% [~, ~, displayOrder] = dendrogram(tree);
% set(gca, 'XTickLabel', topNWords(displayOrder), 'XTickLabelRotation', 90);
% split tree into nclusts distinct clusters
clusterGroups = cluster(tree, 'maxclust', nclusts);

rng('shuffle');
% addpath('visualisation');
cloud = WordCloud.WordCloud(keywords, wordCounts, correlationMatrix, clusterGroups);

end

