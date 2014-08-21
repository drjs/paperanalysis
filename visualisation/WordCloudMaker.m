function WordCloudMaker
cla reset
clear variables
% clear classes
numberClusters = 4;

% load realtestdata
% 
% textHandles = generateTextHandles(words, wordCount, corrMat, tree);
% T = cluster(tree, 'maxclust', numberClusters);
% c = hist(T, numberClusters)

fontBlockSize = 0.02;
prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'};

cx = 0.2;
cy = 0.8;

wh1 = makeWord('string1');
wh2 = makeWord('wh2 added to');
wh3 = makeWord('or is it?');
wh4 = makeWord('kthxbye');
wh5 = makeWord('O RLY?');
wh6 = makeWord('*sad face*');
wh7 = makeWord('to the cloud!');

axis manual

w = WordCluster(wh1, 0.5, 0.5);
% corrMat(1, 2:8)
w = w.addFirst7Words([wh2, wh3, wh4, wh5, wh6, wh7]); %, wordCount(2:8), corrMat(1, 2:8));]); %





end

function w = makeWord(string)
fontBlockSize = 0.02;
prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'};

w = text('String', string, ...
    'FontName', prettyFonts{randi(numel(prettyFonts), 1)}, ... % random pretty font
    'Color', rand(1,3), ...
    'Margin', 1, ...
    'FontUnits', 'normalized', ...
    'FontSize', 4*fontBlockSize, ...
    'Units', 'data', ... % 'normalized', ... %
    'VerticalAlignment', 'middle', ...
    'HorizontalAlignment', 'center', ...
    'Position', [0.5,1] ...
    );
end

