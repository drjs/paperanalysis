classdef WordCloud < handle
    
    properties
        % cell array of fonts to use in clouds. Fonts are randomly selected
        % from this list.
%         prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'}; 
%         prettyFonts;
        
        % The colour to make the figure background. This can be a 1x3 RGB 
        % vector or a standard colour string e.g. 'black' or 'k'.
%         backgroundColour = [1 1 1];
        
        % Scale factor controlling the size the fonts are displayed. Adjust
        % this to make the words bigger or smaller
%         fontScaleFactor;
        
        % Controls how far the outer word clusters are from the central
        % cluster. If the words are too close together or far apart,
        % adjust this value. The distance is proportional to how correlated 
        % the two clusters are.
%         satelliteClusterDistanceScaleFactor;
    end
    
    properties
        figHandle;
        clusters;
        centreX  = 0.5;
        centreY  = 0.5;
        satelliteDistances;
        numWords;
        logoHandle;
    end
        
    methods        
        function this = WordCloud(wordList, wordCounts, wordCorrelations, clusterGroups, settings)
            this.numWords = numel(wordList);
            
            this.initialiseFigure(settings);
            % scale the word counts.
            wordCounts = wordCounts ./ min(wordCounts);
            % initialise clusters
            this.clusters = [];
            
            % process the largest cluster first and smaller ones last
            % find the right order to do the custers in
            clusterOrder = this.sortClustersBySize(clusterGroups, wordCounts);           
           
            % process the clusters in order of size
            for clust = clusterOrder
                idx = (clusterGroups == clust);
                counts = wordCounts(idx);
                words  = wordList(idx);
                correlations = wordCorrelations(idx, idx);
                this = this.makeWordCluster(words, counts, correlations, settings);  
            end
            
            % place the first and biggest cluster in the centre
            this.clusters(1) = this.clusters(1).recentreCluster(this.centreX, this.centreY);
            
            % find base correlation distance between centre cluster and each
            % satellite cluster
            this.satelliteDistances = this.calculateClusterDistancesFromCentre(...
                wordCorrelations, clusterGroups, clusterOrder);
            
            this = this.rescaleClusterSeparation(settings.clusterDistanceFactor);
        end
        
        function this = rescaleText(this, newScaleFactor)
            for cl = 1:numel(this.clusters)
                this.clusters(cl) = this.clusters(cl).rescaleText(newScaleFactor);
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
        
        function this = recolourUniformClusters(this, colourMapFcn)
            colours = colourMapFcn(numel(this.clusters));
            for i = 1:numel(this.clusters)
                this.clusters(i) = this.clusters(i).reColourCluster(colours(i,:));
            end
        end
        
        function this = recolourWithinClusters(this, colourMapFcn)
            for c = this.clusters
                colours = colourMapFcn(c.numWords);
                c.reColourCluster(colours);
            end
        end
        
        function this = recolourByWord(this, colourMapFcn)
            colours = colourMapFcn(this.numWords);
            colourAt = 1;
            for c = this.clusters
                c.reColourCluster(colours(colourAt:(colourAt+c.numWords-1), :));
                colourAt = colourAt + c.numWords;
            end
        end
        
        function this = recolourRandomly(this)
            for c = this.clusters
                colours = rand(c.numWords, 3);
                c.reColourCluster(colours);
            end
        end
        
        function this = recolourWordsUniformly(this, textColour)
            for c = this.clusters
                c.reColourCluster(textColour);
            end
        end  
        
        function this = changeFonts(this, newFonts)
            for c = this.clusters
                c.changeFonts(newFonts);
            end
        end
        
        function this = setLogo(this, state)
            if state
                this.logoHandle = WordCloud.addMWLogo(this.figHandle);
            else
                if ishandle(this.logoHandle)
                    delete(this.logoHandle);
                end
            end
        end
    end
    
    methods (Access = private)
        function this = initialiseFigure(this, settings)
            this.figHandle = figure('Name', 'Word Cloud', ...
                       'Units','normalized', ...
                       'OuterPosition',[0 0 1 1], ...
                       'Color', settings.backgroundColour, ...
                       'InvertHardcopy', 'off');
            % f = figure('Name', 'Word Cloud', 'Position', get(groot,'Screensize'));
            axis manual   
            set(gca, 'Visible', 'off', 'Color', settings.backgroundColour);
        end
        
        function newOrder = sortClustersBySize(~, clusterGroups, wordCounts)
            nclusters = max(clusterGroups);
            groupSizes = zeros(1, nclusters);
            for i = 1:nclusters
                groupSizes(i) = sum(wordCounts(clusterGroups == i));
            end
            [~,newOrder] = sort(groupSizes, 'descend');
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
       
       function this = makeWordCluster(this, words, counts, correlations, settings)
           % find most popular word to put in the centre of the cluster
           [~,mostPopularWord] = max(counts);           
           centreTextHandle = this.makeSingleTextHandle( ...
               words(mostPopularWord), ...
               counts(mostPopularWord), ...
               [1 1 1], ...
               sum(correlations(mostPopularWord,:)), ...
               settings.fonts, ...
               settings.textScaleFactor);
           
           % add text handle to cluster
           this.clusters = [this.clusters, WordCloud.WordCluster(centreTextHandle, 0, 0)];
           
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
                       this.makeSingleTextHandle(...
                            words(i), counts(i), ...
                            [1 1 1], sum(correlations(i,:)), ...
                            settings.fonts, settings.textScaleFactor)]; %#ok<AGROW>
               end
               
               % add remaining words to cluster
               this.clusters(end) = ...
                   this.clusters(end).addWords(textHandles, corr2centre);
           end
       end
       
       function th = makeSingleTextHandle(~, word, wordCount, rgb, totalCorrelation, fonts, textScaleFactor)
           fontBlockSize = 3; % measured in "FontUnits"
           
           th = text('String', word, ...
               'FontName', fonts{randi(numel(fonts), 1)}, ... % random pretty font
               'Color', rgb, ...
               'Margin', 1, ...
               'FontUnit', 'point', ... %'normalized', ...
               'FontSize', wordCount*textScaleFactor, ...
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

