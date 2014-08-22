function WordCloudMaker
% cla reset
clear variables
% clear classes

% load realtestdata
% 
% textHandles = generateTextHandles(words, wordCount, corrMat, tree);
% T = cluster(tree, 'maxclust', numberClusters);
% c = hist(T, numberClusters)


wordsample = {'student','engineering','learning','education','university', ...
    'project','research','study','teaching','skills','technology',...
    'engineers','result','course','programme','design','development',...
    'approach','knowledge','training','different','activities',...
    'courses','professional','level','process','educational',...
    'curriculum','mathematics','higher'};
wordcount = [475,336,227,170,149,118,103,103,90,83,82,77,77,75,74,67,67,63,62,59,56,55,55,53,47,45,44,41,41,40];
wordcount = wordcount./min(wordcount);
wordarray = [];

f = figure('Name', 'Word Cloud', 'Position', [340 340 1000 420]);

for w = 1:numel(wordsample)
    wordarray = [wordarray, makeWord(wordsample(w), wordcount(w))];
end

axis manual
nwords =30;
w = WordCluster(wordarray(1), 0.5, 0.5);
w = w.addWords(wordarray(2:nwords), rand([1,nwords-1])); %, wordCount(2:8), corrMat(1, 2:8));]); %


ax = gca;
ax.Visible = 'off';
f.Color = 'black';


end

function w = makeWord(string, count)
fontBlockSize = 0.02;
prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'};

w = text('String', string, ...
    'FontName', prettyFonts{randi(numel(prettyFonts), 1)}, ... % random pretty font
    'Color', rand(1,3), ...
    'Margin', 1, ...
    'FontUnits', 'normalized', ...
    'FontSize', count*fontBlockSize, ...
    'Units', 'data', ... % 'normalized', ... %
    'VerticalAlignment', 'middle', ...
    'HorizontalAlignment', 'center', ...
    'Position', [0.5,1] ...
    );
end

