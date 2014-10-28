function cloud = generateRandomWordCloud(varargin)
    
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
    % pick nclusters or random number of clusters
    switch nargin
        case 0
            nwords    = 30;
            nclusters = 3 + randi(8);
        case 1
            nwords = varargin{1};
            nclusters = 3 + randi(8);
            if nwords > numel(words)
                nwords = numel(words);
            end
        case 2
            nwords = varargin{1};
            nclusters = varargin{2};
            if nwords > numel(words)
                nwords = numel(words);
            end
    end
    
    % pick a random set of nwords words from the list.
    rng('shuffle'); % seed the rng so it's different each time
    words = words(randperm(nwords));
    
    %% generate random word counts
    wordCountStd = 100;
    wordCountMean = 20;
    nwords = numel(words);
    wordCounts = abs(randn(1,nwords).^2*wordCountStd + wordCountMean);
    wordCounts = ceil(wordCounts);
    % hist(wordCounts, 20);
    
    %% generate correlationMatrix values between -1 and 1
    % generate some random distances (as a matrix). Must be nwords x nwords
    % and reflected along the diagonal.
    distances = zeros(nwords, nwords);
    for i = 1:nwords
        for j = 1:nwords
            if i == j
                distances(i, j) = 1;
                continue;
            end
            distances(i, j) = randn(1);
            distances(j, i) = distances(i, j);
        end
    end
    % along the diagonal should be 1 because something should be perfectly
    % correlated with itself.
    distances(logical(eye(nwords))) = 1;
    
    %% generate clustering
    % randomly distribute words into different clusters
    clusterGroups = randi(nclusters, 1, nwords);
    
    %% generate cloud
    cloud = WordCloud(words, wordCounts, distances, clusterGroups);
end