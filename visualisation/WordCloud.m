classdef WordCloud
    
    properties (Constant = true)
        prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'}; 
        fontScaleFactor = 1;
    end
    
    properties
        clusters;
    end
    
    methods
        function this = WordCloud(wordList, wordCounts, wordCorrelations, clusterGroups)
            % scale the word counts.
            wordCounts = wordCounts ./ min(wordCounts);
            % initialise clusters
            this.clusters = [];
            
            % process the largest cluster first and smaller ones last
            % find the right order to do the custers in
            [sizeCluster,~]  = histcounts(clusterGroups);
            [~,clusterOrder] = sort(sizeCluster, 'descend');
            
            % process the clusters in order
            for clust = clusterOrder
                idx = (clusterGroups == clust);
                counts = wordCounts(idx);
                words  = wordList(idx);
                correlations = wordCorrelations(idx, idx);
                this = this.makeWordCluster(words, counts, correlations);  
            end
            
            % place the first and biggest cluster in the centre
            this.clusters(1).recentreCluster(0.5, 0.5);
        end
    end
    
    methods (Access = private)
       % function tf = isClusterOverlap(cluster1, cluster2)
       
       function this = makeWordCluster(this, words, counts, correlations)
           % find most popular word to put in the centre of the cluster
           [~,mostPopularWord] = max(counts);           
           centreTextHandle = this.makeSingleTextHandle( ...
               words(mostPopularWord), ...
               counts(mostPopularWord), ...
               [1 0 0], ...
               sum(correlations(mostPopularWord,:)) );
           
           % add text handle to cluster
           this.clusters = [this.clusters, WordCluster(centreTextHandle, 0, 0)];
           
           % create text handles for remaining words
           words(mostPopularWord)  = [];
           if numel(words) > 0
               counts(mostPopularWord) = [];
               corr2centre = correlations(mostPopularWord, :);
               corr2centre(mostPopularWord) = [];
               correlations(mostPopularWord, :) = [];
               textHandles = [];
               
               for i = 1:numel(words)
                   textHandles = [textHandles, ...
                       this.makeSingleTextHandle(words(i), counts(i), [1 0 1], sum(correlations(i,:)) )];
               end
               
               % add remaining words to cluster
               this.clusters(end) = ...
                   this.clusters(end).addWords(textHandles, corr2centre);
           end
       end
       
       function th = makeSingleTextHandle(this, word, wordCount, rgb, totalCorrelation)
           fontBlockSize = 0.02; % measured in "FontUnits"
           
           th = text('String', word, ...
               'FontName', this.prettyFonts{randi(numel(this.prettyFonts), 1)}, ... % random pretty font
               'Color', rand(1,3), ...
               'Margin', 1, ...
               'FontUnits', 'normalized', ...
               'FontSize', wordCount*this.fontScaleFactor*fontBlockSize, ...
               'Units', 'data', ... % 'normalized', ... %
               'VerticalAlignment', 'middle', ...
               'HorizontalAlignment', 'center', ...
               'Position', [0,0] ...
               );
           
           % find out how many font blocks tall and wide the text is
           userData.blocksWide = ceil(th.Extent(3)/fontBlockSize);
           userData.blocksHigh = ceil(th.Extent(4)/fontBlockSize);
           userData.wordCount  = wordCount;
           userData.tCorr      = totalCorrelation;
           set(th, 'UserData', userData);
       end
    end
    
end

