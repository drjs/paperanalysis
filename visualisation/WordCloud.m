classdef WordCloud
    
    properties (Constant = true)
        % cell array of fonts to use in clouds. Fonts are randomly selected
        % from this list.
        prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'}; 
        
        % The colour to make the figure background. This can be a 1x3 RGB 
        % vector or a standard colour string e.g. 'black' or 'k'.
        backgroundColour = [0 0 0];
        
        % Scale factor controlling the size the fonts are displayed. Adjust
        % this to make the words bigger or smaller
        fontScaleFactor = 1;
        
        % Controls how far the outer word clusters are from the central
        % cluster. If the words are too close together or far apart,
        % adjust this value. The distance is proportional to how correlated 
        % the two clusters are.
        satelliteClusterDistanceScaleFactor = 0.5;
    end
    
    properties
        clusters;
        allTextHandles = [];
        centreX  = 0.5;
        centreY  = 0.5;
        satelliteDistances;
    end
    
    methods
        function this = WordCloud(wordList, wordCounts, wordCorrelations, clusterGroups)
            this.initialiseFigure();
            % scale the word counts.
            wordCounts = wordCounts ./ min(wordCounts);
            % initialise clusters
            this.clusters = [];
            
            % process the largest cluster first and smaller ones last
            % find the right order to do the custers in
            clusterOrder = this.sortClustersBySize(clusterGroups, wordCounts);
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
            
            % find base correlation distance between centre cluster and each
            % satellite cluster
            this.satelliteDistances = this.calculateClusterDistancesFromCentre(...
                wordCorrelations, clusterGroups, clusterOrder);
            
            this = this.rescaleClusterSeparation(this.satelliteClusterDistanceScaleFactor);
        end
        
        function this = rescaleText(this, newScaleFactor)
            resizeFcn = @(h)set(h, 'FontSize', ...
                 h.UserData.wordCount*newScaleFactor*3);
            arrayfun(resizeFcn, this.allTextHandles);

            for cl = 1:numel(this.clusters) % is there no way to vectorise this?
               this.clusters(cl) = this.clusters(cl).respaceRowsHorizontally(); 
               this.clusters(cl) = this.clusters(cl).respaceRowsVertically(); 
            end
        end
        
        function this = rescaleClusterSeparation(this, newDistanceScaleFactor)            
            % for the remaining clusters
            distances = ( this.satelliteDistances./max(this.satelliteDistances) ) .* newDistanceScaleFactor;
            nClusters = numel(this.clusters);
            
            for clust = 2:nClusters
                % go in a circle around the centre starting from ~45deg
                theta = (2*pi*clust/(nClusters-1)) + (pi/4);
                
                % places this cluster some distance from centre, proportional
                % to the correlation between the two clusters.
                newX = cos(theta).*distances(clust) + this.centreX;
                newY = sin(theta).*distances(clust) + this.centreY;
                this.clusters(clust) = this.clusters(clust).recentreCluster(newX, newY);
            end
        end
    end
    
    methods (Access = private)
        function this = initialiseFigure(this)
            f = figure('Name', 'Word Cloud', ...
                'Units','normalized','OuterPosition',[0 0 1 1]);
            % f = figure('Name', 'Word Cloud', 'Position', get(groot,'Screensize'));
            axis manual   
            set(gca, 'Visible', 'off');
            f.Color = this.backgroundColour;
        end
        
        function newOrder = sortClustersBySize(this, clusterGroups, wordCounts)
            nclusters = max(clusterGroups);
            groupSizes = zeros(1, nclusters);
            for i = 1:nclusters
                groupSizes(i) = sum(wordCounts(clusterGroups == i));
            end
            [~,newOrder] = sort(groupSizes, 'descend');
        end
        
        function this = recalculateLimits(this)
            left   = min([this.clusters.left]);
            right  = max([this.clusters.right]);
            top    = max([this.clusters.top]);
            bottom = min([this.clusters.bottom]);
            % rectangle('position', [left, bottom, right-left, top-bottom], 'edgecolor', 'b');
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
                % changes to 0 = close 2 = far
                corr = (corr.*-1) + 1;
                % sum correlation to get total distance from centre cluster
                dists(clust) = max(corr(:));
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
           % add text handle to text handles vector
           this.allTextHandles = [this.allTextHandles, centreTextHandle];
           
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
               
               % add all text handles to text handles vector
               this.allTextHandles = [this.allTextHandles, textHandles];
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

