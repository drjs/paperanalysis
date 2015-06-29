classdef WordCloudFactory
    %WORDCLOUDFACTORY contains display settings and controls how the word
    %cloud is generated. A ParseFiles object is required before building a 
    %cloud to provide a set of words and their counts.
    %
    % It is possible to edit the word cloud programmatically using this
    % class, however it is recommended to use the WordCloudEditor GUI for
    % ease of use.
    %
    % See also:
    % WordCloud, WordCloudEditor
    %
    % Author: Jenny Owen
    % Copyright 2015 The MathWorks Inc.
    
    % read only properties
    properties (SetAccess = private)
        colouringModes = {'Uniform clusters', ... 
                          'Colour within cluster', ...
                          'Colour by word', ...
                          'Random word colouring', ...
                          'Uniform word colouring'};
        possibleColourMapNames;
        backgroundColour;
        textColour;
        numWords;
        colourMap;
        fonts;
        colourMode;
        textScaleFactor;
        numClusters;
        clusterDistanceFactor;
        clusterWidthRatio;
        hasLogo;
    end
    
    properties (Access = private)
        possibleColourMaps = {@parula, @jet, @hsv, @hot, @cool, @spring, ...
                    @summer, @autumn, @winter, @gray, @bone, @copper, @pink};
        hasStatsToolbox;
        cloud;
    end
    
    methods
        function obj = WordCloudFactory()
            obj.backgroundColour       = [0 0 0];
            obj.textColour             = [1 1 1];
            obj.numWords               = 75;
            obj.colourMap              = @parula;
            obj.fonts                  = {'Times New Roman'};
            obj.colourMode             = obj.colouringModes{3};  
            obj.textScaleFactor        = 2;
            obj.numClusters            = 1;
            obj.clusterDistanceFactor  = 0.5;
            obj.clusterWidthRatio      = 4;
            obj.hasLogo                = true;       
            
            obj.possibleColourMapNames = cellfun(@func2str, obj.possibleColourMaps, 'UniformOutput', false);
            obj.hasStatsToolbox        = WordCloud.checkForStatisticsToolbox();
        end
        
        function obj = loadSettingsFromMatFile(obj, filename)
            cache = load(filename);
            obj.backgroundColour       = cache.backgroundColour;
            obj.textColour             = cache.textColour;
            obj.numWords               = cache.numWords;
            obj.colourMap              = cache.colourMap;
            obj.fonts                  = cache.fonts;
            obj.colourMode             = cache.colourMode;
            obj.textScaleFactor        = cache.textScaleFactor;
            obj.numClusters            = cache.numClusters;
            obj.clusterDistanceFactor  = cache.clusterDistanceFactor;
            obj.clusterWidthRatio      = cache.clusterWidthRatio;
            obj.hasLogo                = cache.hasLogo;
        end
        

        function obj = buildCloud(obj, docParser)
            % this is unlikely to ever be true, but it's worth checking
            % anyway.
            if numel(docParser.uniqueWords) < obj.numWords
                obj.numWords = numel(docParser.uniqueWords);
            end
            
            keywords = docParser.uniqueWords(1:obj.numWords);
            wordCounts = docParser.wordCounts(1:obj.numWords, :);
            wordCounts = sum(wordCounts, 2);
            normalisedWordCounts = docParser.normalisedWordCounts(1:obj.numWords, :);
            
            % if the statistics toolbox is present then statistial analysis
            % is possible
            if obj.hasStatsToolbox
                % correlationMatrix = corr(normalisedWordCounts', 'type', 'Pearson');
                correlationMatrix = corr(docParser.wordCounts(1:obj.numWords, :)', 'type', 'Pearson');
                tree = linkage(correlationMatrix, 'average');
                clusterGroups = cluster(tree, 'maxclust', obj.numClusters);
            else
                % otherwise only one cluster is possible
                correlationMatrix = randn(obj.numWords, obj.numWords);
                % correlationMatrix = ones(obj.numWords, obj.numWords);
                clusterGroups = ones(obj.numWords, 1);
            end
            obj.cloud = WordCloud.WordCloud(keywords, wordCounts, correlationMatrix, clusterGroups, obj);
            obj = obj.recolourCloud();
            obj.cloud = obj.cloud.setLogo(obj.hasLogo);
        end
              
        function obj = setColourMap(obj, idx)
            obj.colourMap = obj.possibleColourMaps{idx};
            obj = obj.recolourCloud();
        end
        
        function idx = getColourMapIdx(obj)
            findCmap = ismember(obj.possibleColourMapNames, func2str(obj.colourMap));
            idx = 1:numel(obj.possibleColourMapNames);
            idx = idx(findCmap);
        end
        
        function obj = setColourMode(obj, idx)
            obj.colourMode = obj.colouringModes{idx};
            obj = obj.recolourCloud();
        end
        
        function idx = getColourModeIdx(obj)
            findMode = ismember(obj.colouringModes, obj.colourMode);
            idx = 1:numel(obj.colouringModes);
            idx = idx(findMode);
        end
        
        function obj = setTextColour(obj, newColour)
            obj.textColour = newColour;
            obj = obj.recolourCloud();
        end
            
        function obj = setBackgroundColour(obj, newColour)
            obj.backgroundColour = newColour;
            obj.cloud.figHandle.Color = newColour;  
            obj.cloud = obj.cloud.setLogo(obj.hasLogo);          
        end
        
        function obj = setHasLogo(obj, newState)
            obj.hasLogo = newState;
            obj.cloud = obj.cloud.setLogo(newState);
        end
        
        function obj = setFonts(obj, fontList)
            obj.fonts = fontList;
            obj.cloud = obj.cloud.setFonts(fontList);
        end
        
        function obj = setTextScale(obj, newSize)
            obj.textScaleFactor = newSize;
            obj.cloud = obj.cloud.rescaleText(newSize);
        end
        
        function obj = setNumWords(obj, numWords, docParser)
            obj.numWords = numWords;
            delete(obj.cloud.figHandle);
            delete(obj.cloud);
            obj = obj.buildCloud(docParser);
        end
                
        function obj = setNumClusters(obj, numClusters, docParser)
            obj.numClusters = numClusters;
            delete(obj.cloud.figHandle);
            delete(obj.cloud);
            obj = obj.buildCloud(docParser);
        end
        
        function obj = setClusterSeparation(obj, newDistance)
            obj.clusterDistanceFactor = newDistance;
            obj.cloud = obj.cloud.rescaleClusterSeparation(newDistance);
        end
        
        function obj = setClusterWidthRatio(obj, newRatio)
            obj.clusterWidthRatio = newRatio;
            obj.cloud = obj.cloud.setClusterWidthRatio(newRatio);
        end
        
        function obj = recolourCloud(obj)
            switch obj.colourMode
                case 'Uniform clusters'
                    obj.cloud.recolourUniformClusters(obj.colourMap);
                case 'Colour within cluster'
                    obj.cloud = obj.cloud.recolourWithinClusters(obj.colourMap);
                case 'Colour by word'
                    obj.cloud.recolourByWord(obj.colourMap);
                case 'Random word colouring'
                    obj.cloud.recolourRandomly();
                case 'Uniform word colouring'
                    obj.cloud.recolourWordsUniformly(obj.textColour);
            end
        end
        
        function h = getCloudFigureHandle(obj)
            h = obj.cloud.figHandle;
        end
    end
    
end

