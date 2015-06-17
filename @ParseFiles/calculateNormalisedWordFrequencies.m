function obj = calculateNormalisedWordFrequencies(obj)
%CALCULATENORMALISEDWORDFREQUENCIES Calculates the normalised word
%frequencies for the semantic surface and word cloud visualisations.

% === Pantelis code ===

numWords = size(obj.wordCounts, 1);
numDocs  = size(obj.wordCounts, 2);

% TF-IDF normalization (Term Frequency. * Inverse Docum. Frequency)
FreqCounts = bsxfun(@rdivide, obj.wordCounts, sum(obj.wordCounts));
TF = log( FreqCounts + 1);
IDF = log( numDocs ./ (  sum( ~(obj.wordCounts' <2*eps) ) + 1) );
WordFreq_tfidf = TF .* repmat(IDF',1, numDocs);

% L2 Normalization
DocFreqNorms = cellfun(@norm, num2cell(WordFreq_tfidf,1));
obj.normalisedWordCounts =  WordFreq_tfidf./repmat(DocFreqNorms,[numWords 1]);

end

