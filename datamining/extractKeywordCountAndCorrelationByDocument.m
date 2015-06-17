function [DocFreq, correlationMatrix] = extractKeywordCountAndCorrelationByDocument(uniqueKeywords, abstracts)
%EXTRACTKEYWORDCOUNTANDCORRELATIONBYDOCUMENT 
% UNIQUEKEYWORDS list of N keywords to count occurences of
% ABSTRACTS cell of document abstracts. array one cell per abstract. 1xD
% where D is the number of documents.
% DOCFREQ keyword count for each document (normalised by how frequency the 
% word occurs across all documents). Size NxD.
% CORRELATIONMATRIX how correlated each word is with each other word in
% the form of an NxN matrix.

nwords = numel(uniqueKeywords);
ndocs  = numel(abstracts);
WordCounts = zeros(nwords,ndocs);

% Simple counting Words / Documents
for i=1:nwords
    for j = 1:ndocs    
        WordCounts(i,j) = nnz(ismember( strsplit(abstracts{j}), uniqueKeywords{i}));
    end
end

% TF-IDF normalization (Term Frequency. * Inverse Docum. Frequency)
FreqCounts = bsxfun(@rdivide,WordCounts,sum(WordCounts));
TF = log( FreqCounts + 1);
IDF = log( ndocs ./ (  sum( ~(WordCounts' <2*eps) ) + 1) );
WordFreq_tfidf = TF .* repmat(IDF',1, ndocs);

% L2 Normalization
DocFreqNorms = cellfun(@norm, num2cell(WordFreq_tfidf,1));
DocFreq =  WordFreq_tfidf./repmat(DocFreqNorms,[nwords 1]);
correlationMatrix = corr(DocFreq', 'type', 'Pearson');

end

