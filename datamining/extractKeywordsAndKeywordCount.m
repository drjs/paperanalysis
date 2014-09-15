function [uniqueKeywords, keywordFrequency] = extractKeywordsAndKeywordCount(wholeBody)
%EXTRACTKEYWORDSANDKEYWORDCOUNT Takes a large section of text and finds the
%keywords and how frequently the keywords occured.

% Delete small words
L = cellfun(@length, wholeBody);
wholeBody(L <= 3) = [];

% Make lower case
wholeBody = lower(wholeBody);

% Construct the dictionary
uniqueKeywords = unique(wholeBody);

fileid = fopen('CommonWords100oxforddictionaries.com.txt');
Wcommon = textscan(fileid, '%s');
if fileid ~=-1
    fclose(fileid);
end
Wcommon = Wcommon{1};

uniqueKeywords(ismember(uniqueKeywords,Wcommon)) = [];

n = length(uniqueKeywords);
keywordFrequency = zeros(n,1);
for i=1:n
    keywordFrequency(i) = nnz(ismember(wholeBody,uniqueKeywords{i}));
end

[keywordFrequency, idx] = sort(keywordFrequency, 'descend');
uniqueKeywords = uniqueKeywords(idx);
% T = table(uniqueKeywords',freq,'VariableNames',{'Vocabulary' 'Freq'});

% clear idx fileid Wcommon wholeBody freq i ans n L2 L



end

