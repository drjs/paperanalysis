classdef WordCloudFactory
    %WORDCLOUDSETTINGS Holds settings for the word cloud. 
    % Automatically finds the defaults on startup.
    %   * background colour
    %   * word colours? coloured randomly, by cluster or by correllated-to-other-words-ness (have transparency represent correllation maybe?)
    %   * Fonts. My choices are not always present on the system. Use UISETFONT function.
    %   * word scaling generally
    %   * word size with respect to popularity. Maybe make a histogram?
    %   * cluster separation: how far apart are the clusters.
    %   * cluster width/height ratio?
    %   * presence of MATLAB logo?
    
    
    % read only properties
    properties (SetAccess = private)
        colouringModes = {'Uniform clusters', ... 
                          'Colour within cluster', ...
                          'Colour by word', ...
                          'Random word colouring', ...
                          'Uniform word colouring'};
        possibleColourMapNames;
%         {'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', ...
%                     'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink'};
        backgroundColour;
        textColour;
        numWords;
        colourMap;
        fonts;
        colourMode;
        textScaleFactor;
        numClusters;
        clusterDistanceFactor;
        hasLogo;
    end
    
    properties (Access = private)
        prefgroup = 'WordCloud';
        possibleColourMaps = {@parula, @jet, @hsv, @hot, @cool, @spring, ...
                    @summer, @autumn, @winter, @gray, @bone, @copper, @pink};
        cloud;
        logoHandle;
    end
    
    methods
        function obj = WordCloudFactory()
            obj.backgroundColour       = getpref(obj.prefgroup, 'backgroundColour', [0 0 0]);
            obj.textColour             = getpref(obj.prefgroup, 'textColour', [1 1 1]);
            obj.numWords               = getpref(obj.prefgroup, 'numWords', 75);
            obj.colourMap              = getpref(obj.prefgroup, 'colourMap', @parula);
            obj.fonts                  = getpref(obj.prefgroup, 'fonts', {'Times New Roman'});
            obj.colourMode             = getpref(obj.prefgroup, 'colourMode', obj.colouringModes{2});  
            obj.textScaleFactor        = getpref(obj.prefgroup, 'textScaleFactor', 2);
            obj.numClusters            = getpref(obj.prefgroup, 'numClusters', 1);
            obj.clusterDistanceFactor  = getpref(obj.prefgroup, 'clusterDistanceFactor', 0.5);
            obj.hasLogo                = getpref(obj.prefgroup, 'hasLogo', true);       
            
            obj.possibleColourMapNames = cellfun(@func2str, obj.possibleColourMaps, 'UniformOutput', false);
        end
        
        function obj = clearAllPreferences(obj)
            rmpref(obj.prefgroup, 'backgroundColour');
            rmpref(obj.prefgroup, 'textColour');
            rmpref(obj.prefgroup, 'numWords');
            rmpref(obj.prefgroup, 'colourMap');
            rmpref(obj.prefgroup, 'fonts');
            rmpref(obj.prefgroup, 'colourMode');  
            rmpref(obj.prefgroup, 'textScaleFactor');
            rmpref(obj.prefgroup, 'numClusters');
            rmpref(obj.prefgroup, 'clusterDistanceFactor');
            rmpref(obj.prefgroup, 'hasLogo');   
        end
        
        function obj = buildCloud(obj, docParser)
            keywords = docParser.uniqueWords(1:obj.numWords);
            wordCounts = docParser.wordCounts(1:obj.numWords, :);
            wordCounts = sum(wordCounts, 2);
            normalisedWordCounts = docParser.normalisedWordCounts(1:obj.numWords, :);
            
            % if the statistics toolbox is present then statistial analysis
            % is possible
            if license('test', 'Statistics_Toolbox') == 1
                correlationMatrix = corr(normalisedWordCounts', 'type', 'Pearson');
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
            setpref(obj.prefgroup, 'colourMap', obj.colourMap);
            obj = obj.recolourCloud();
        end
        
        function idx = getColourMapIdx(obj)
            findCmap = ismember(obj.possibleColourMapNames, func2str(obj.colourMap));
            idx = 1:numel(obj.possibleColourMapNames);
            idx = idx(findCmap);
        end
        
        function obj = setColourMode(obj, idx)
            obj.colourMode = obj.colouringModes{idx};
            setpref(obj.prefgroup, 'colourMode', obj.colourMode);
            obj = obj.recolourCloud();
        end
        
        function idx = getColourModeIdx(obj)
            findMode = ismember(obj.colouringModes, obj.colourMode);
            idx = 1:numel(obj.colouringModes);
            idx = idx(findMode);
        end
        
        function obj = setTextColour(obj, newColour)
            obj.textColour = newColour;
            setpref(obj.prefgroup, 'textColour', newColour);
            obj = obj.recolourCloud();
        end
            
        function obj = setBackgroundColour(obj, newColour)
            obj.backgroundColour = newColour;
            setpref(obj.prefgroup, 'backgroundColour', newColour);
            obj.cloud.figHandle.Color = newColour;  
            obj.cloud = obj.cloud.setLogo(obj.hasLogo);          
        end
        
        function obj = setHasLogo(obj, newState)
            obj.hasLogo = newState;
            setpref(obj.prefgroup, 'hasLogo', newState);
            obj.cloud = obj.cloud.setLogo(newState);
        end
        
        function obj = setFonts(obj, fontList)
            obj.fonts = fontList;
            setpref(obj.prefgroup, 'fonts', fontList);
            obj.cloud = obj.cloud.changeFonts(fontList);
        end
        
        function obj = setTextScale(obj, newSize)
            obj.textScaleFactor = newSize;
            obj.cloud = obj.cloud.rescaleText(newSize);
            setpref(obj.prefgroup, 'textScaleFactor', newSize);
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
        

    end
    
end

