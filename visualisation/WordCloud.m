classdef WordCloud
    
    properties (Constant = true)
        prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'}; 
        fontScaleFactor = 3;
        satelliteClusterDistanceScaleFactor = 0.5;
    end
    
    properties
        clusters;
        centreX  = 0.5;
        centreY  = 0.5;
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
            nClusters = numel(clusterOrder);    
            
            % generate colours for each cluster
            cols = flip(parula(nClusters));
            
            % process the clusters in order
            for clust = clusterOrder
                idx = (clusterGroups == clust);
                counts = wordCounts(idx);
                words  = wordList(idx);
                correlations = wordCorrelations(idx, idx);
                this = this.makeWordCluster(words, counts, correlations, cols(clust,:));  
            end
            
            % place the first and biggest cluster in the centre
            this.clusters(1) = this.clusters(1).recentreCluster(this.centreX, this.centreY);
            
            % find correlation distance between centre cluster and each
            % satellite cluster
            dists = this.calculateClusterDistancesFromCentre(...
                wordCorrelations, clusterGroups, clusterOrder);
            
            % for the remaining clusters
            for clust = 2:nClusters                
                distance = ( dists(clust)/max(dists) ) * this.satelliteClusterDistanceScaleFactor;
                
                % go in a circle around the centre starting from the top
                theta = (2*pi*clust/(nClusters-1));
                
                % places this cluster some distance from centre, proportional
                % to the correlation between the two clusters.
                newX = cos(theta).*distance + this.centreX;
                newY = sin(theta).*distance + this.centreY;
                this.clusters(clust) = this.clusters(clust).recentreCluster(newX, newY);
                c = this.clusters(clust)
%                 rectangle('position', [c.left, c.bottom, c.right-c.left, c.top-c.bottom], 'edgecolor', 'r');
            end
        end
        
        function this = boxEachCluster(this)
            for c = this.clusters
                rectangle('position', [c.left, c.bottom, c.right-c.left, c.top-c.bottom], 'edgecolor', 'r');
            end
            this = recalculateLimits(this);
        end
    end
    
    methods (Access = private)
       % function tf = isClusterOverlap(cluster1, cluster2)
       function this = recalculateLimits(this)
            left   = min([this.clusters.left]);
            right  = max([this.clusters.right]);
            top    = max([this.clusters.top]);
            bottom = min([this.clusters.bottom]);
            rectangle('position', [left, bottom, right-left, top-bottom], 'edgecolor', 'b');
            % axis([left, right, bottom, top]);
            % set(gcf, 'Position', [left, bottom, right-left, top-bottom]);
        end
       
       function dists = calculateClusterDistancesFromCentre(~, wordCorrelations, clusterGroups, clusterOrder)
           % returns array of total distances between all the words in the
           % central cluster and each satellite clusters.
           % dists is ordered by cluster population, and is the same order
           % as this.clusters.
           nClusters = max(clusterGroups);
           dists = zeros(1,nClusters);
           
           centreClusterWordIdx = (clusterGroups == clusterOrder(1));
           
           for clust = 2:nClusters
                % find correlation distance between centre cluster and current one
                corr = wordCorrelations(centreClusterWordIdx, ...
                    (clusterGroups == clusterOrder(clust)) );
                % scale corr so that 1 = close and -1 = far
                corr = (corr.*-1) + 1;
                % sum correlation to get total distance from centre cluster
                dists(clust) = mean(corr(:));
            end
       end
       
       function this = makeWordCluster(this, words, counts, correlations, coreColour)
           % find most popular word to put in the centre of the cluster
           [~,mostPopularWord] = max(counts);           
           centreTextHandle = this.makeSingleTextHandle( ...
               words(mostPopularWord), ...
               counts(mostPopularWord), ...
               coreColour, ...
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
                       this.makeSingleTextHandle(words(i), counts(i), coreColour, sum(correlations(i,:)) )]; %#ok<AGROW>
               end
               
               % add remaining words to cluster
               this.clusters(end) = ...
                   this.clusters(end).addWords(textHandles, corr2centre);
           end
       end
       
       function th = makeSingleTextHandle(this, word, wordCount, rgb, totalCorrelation)
           fontBlockSize = 3; % measured in "FontUnits"
           
           th = text('String', word, ...
               'FontName', this.prettyFonts{randi(numel(this.prettyFonts), 1)}, ... % random pretty font
               'Color', rgb, ...
               'Margin', 1, ...
               'FontUnit', 'point', ... %'normalized', ...
               'FontSize', wordCount*this.fontScaleFactor*fontBlockSize, ...
               'Units', 'data', ... % 'normalized', ... %
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
