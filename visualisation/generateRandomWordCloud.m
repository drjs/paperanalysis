function [words, wordCount, corrMat, tree] = generateRandomWordClusters(varargin)
    
    %% generate random list using an existing wordlist....
    words = {'apple', 'apricot', 'avocado', 'banana', 'berry', 'blackberry', ...
        'blood orange', 'blueberry', 'cantaloupe', 'cherry', 'citron', 'citrus', ...
        'coconut','crabapple', 'cranberry', 'currant', 'date', 'dragonfruit', ...
        'durian', 'elderberry', 'fig', 'grape', 'grapefruit', 'guava', 'honeydew', ...
        'kiwi', 'kumquat', 'lemon', 'lime', 'lingonberry', 'loquat', 'lychee', ...
        'mandarin orange', 'mango', 'melon', 'nectarine', 'orange', 'papaya', ...
        'passion fruit', 'peach', 'pear', 'persimmon', 'pineapple', 'plantain', ...
        'plum', 'pomegranite', 'prune', 'quince', 'raisin', 'raspberry', ...
        'star fruit', 'strawberry', 'tangelo', 'tangerine', 'watermelon'};
    % pick N or 30 random words
    if nargin == 0
        nwords = 30;
    else
        nwords = varargin{1};
    end
    
    words = words(randperm(nwords));
    
    %% generate random word counts
    wordCountStd = 25;
    wordCountMean = 10;
    nwords = numel(words);
    wordCount = round(abs(rand([1,nwords])*wordCountStd + wordCountMean));
    
    %% generate correlationMatrix values between -1 and 1
    % how many independent distances are there between nwords points?
    ndistances = sum(1:(nwords-1));
    % generate some random distances (as a vector) for the linkage function
    % use a sin function to make some clusters.
%     distances = (rand(1,ndistances).*2)-1;
    distances = sin((10*pi/ndistances).*(1:ndistances));
    % the correlation matrix is a nice square version of these distances
    % where corrMat(word1, word2) gives the correlation between any 2 words
    corrMat = squareform(distances);
    
    %% generate clustering
    % linkage does not like negative numbers and 0 indicates closeness and
    % 1 difference, so this needs rescaling
    rescaledDistances = (-0.5*distances+0.5);
    tree = linkage(rescaledDistances);
    bestOrder = optimalleaforder(tree, rescaledDistances);
    hdendro = dendrogram(tree, 'Reorder', bestOrder);
    set(gca, 'XTickLabel', words(bestOrder), 'XTickLabelRotation',90);
    
end