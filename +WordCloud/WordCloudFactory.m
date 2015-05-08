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
    
    properties
        backgroundColour;
        textColour;
        colourMap;
        fonts;
        colourMode;
        textScaleFactor;
        numClusters;
        clusterDistanceFactor;
        hasLogo;
    end
    
    % read only properties
    properties (SetAccess = private)
        possibleColourMapNames = {'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', ...
                    'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink'};
        colouringModes = {'Uniform clusters', ... 
                          'Colour within cluster', ...
                          'Colour by word', ...
                          'Random word colouring', ...
                          'Uniform word colouring'};
    end
    
    properties (Access = private)
        prefgroup = 'WordCloud';
        possibleColourMaps = {@parula, @jet, @hsv, @hot, @cool, @spring, ...
                    @summer, @autumn, @winter, @gray, @bone, @copper, @pink};
    end
    
    methods
        function obj = WordCloudFactory()
            obj.backgroundColour       = getpref(obj.prefgroup, 'backgroundColour', [0 0 0]);
            obj.textColour             = getpref(obj.prefgroup, 'textColour', [1 1 1]);
            obj.colourMap              = getpref(obj.prefgroup, 'colourMap', @parula);
            obj.fonts                  = getpref(obj.prefgroup, 'fonts', {'Times New Roman'});
            obj.colourMode             = getpref(obj.prefgroup, 'colourMode', 1);  
            obj.textScaleFactor        = getpref(obj.prefgroup, 'textScaleFactor', 2);
            obj.numClusters            = getpref(obj.prefgroup, 'numClusters', 1);
            obj.clusterDistanceFactor  = getpref(obj.prefgroup, 'clusterDistanceFactor', 0.5);
            obj.hasLogo                = getpref(obj.prefgroup, 'hasLogo', true);            
        end
        
        function obj = clearAllPreferences(obj)
            rmpref(obj.prefgroup, 'backgroundColour');
            rmpref(obj.prefgroup, 'textColour');
            rmpref(obj.prefgroup, 'colourMap');
            rmpref(obj.prefgroup, 'fonts');
            rmpref(obj.prefgroup, 'colourMode');  
            rmpref(obj.prefgroup, 'textScaleFactor');
            rmpref(obj.prefgroup, 'numClusters');
            rmpref(obj.prefgroup, 'clusterDistanceFactor');
            rmpref(obj.prefgroup, 'hasLogo');   
        end
    end
    
end

