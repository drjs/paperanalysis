function textHandles = generateTextHandles(words, wordCount, corrMat, tree)
    %GENERATETEXTHANDLES Generates nicely coloured and sized text handles
    %for use with the visualisation
    % WORDS a cell array containing N text strings to turn into handles.
    % WORDCOUNTS the number of times each word was counted, so it can be
    % resized appropriately
    % CORRMAT a N x N matrix with data ranged -1 (fully anti correlated)
    % to 1 (fully correlated) describing how correlated each word is with
    % each other word.
    
    
    
    % automatically calculate the best order for the words to go in for best
    % clustering
    % todo: THIS IS PROBABLY NOT THE BEST ORDERING ALGORITHM.
    %bestOrder = optimalleaforder(tree, squareform(corrMat)+1);
    f = figure;
    [~,~,bestOrder] = dendrogram(tree);
    close(f);
    
    colours = generateWordRGBColours(bestOrder, corrMat);
    
    % draw some text
    textHandles = [];
    mat = sum(corrMat);
    
    for i = 1:numel(words)
       textHandles = [textHandles, ...
        makeATextHandle(words(i), wordCount(i), colours(i,:), mat(i))];
    end
    
    % add all text to text group
    % cellfun(@(th) set(th, 'Parent', textGroup), textHandles);
    % adding things into a group seems to flip the ordering, so...
    % textGroup.Children = flip(textGroup.Children);
end

function jLength = calculateJourneyLength(journey, corrMat)
       x1 = journey(1:(end-1));
       x2 = journey(2:end);
       
       % this neat line makes a vector [A(x1(1), x2(1)); A(x1(2), x2(2)); 
       % A(x1(3), x2(3)); A(x1(4), x2(4));  etc ]
       distanceBetweenOrderedWords = corrMat(sub2ind(size(corrMat), x1, x2));
       jLength = cumsum([0 distanceBetweenOrderedWords]);
end

function colours = generateWordRGBColours(wordOrder, corrMat)
    % will make an Nx3 matrix, where N is the number of words.
    % step through the words in the best order, to find the cumulative distance
    % travelled and the total distance travelled.
    
    % rescale correlation matrix to 0 for most correlation to 1 for least.
    extremifyColouringFactor = 2; % makes colour difference more noticable when there is a big step between words.
    rescaledCorrMat = (-0.5*corrMat+0.5).^extremifyColouringFactor;
    
    cumulativeWordDistances = calculateJourneyLength(wordOrder, rescaledCorrMat);
    totalWordDistance = cumulativeWordDistances(end);
    
    % use cumulative word distances to scale the word colouring
    mapIndex = round(cumulativeWordDistances ./ (totalWordDistance / 255))+1;
    colmap = parula(256);
    colours = colmap(mapIndex, :);
end


function th = makeATextHandle(word, wordCount, rgb, totalCorrelation)
    fontScaleFactor = log10(wordCount);
    fontBlockSize = 0.002; % measured in "FontUnits"
    makeBackground = false;
    prettyFonts = {'Century Gothic', 'Cooper Black', 'Magneto Bold'};   
    
    th = text('String', word, ...
        'FontName', prettyFonts{randi(numel(prettyFonts), 1)}, ... % random pretty font
        'Color', rgb, ...
        'Margin', 1, ...
        'FontUnits', 'normalized', ...
        'FontSize', (wordCount/fontScaleFactor)*fontBlockSize, ...
        'Units', 'data', ... % 'normalized', ... %
        'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'center', ...
        'Position', [0,0] ...
        );
    if makeBackground
        set(th, 'BackgroundColor', 1-rgb);
    end
    % find out how many font blocks tall and wide the text is
    userData.blocksWide = ceil(th.Extent(3)/fontBlockSize);
    userData.blocksHigh = ceil(th.Extent(4)/fontBlockSize);
    userData.wordCount  = wordCount;
    userData.tCorr      = totalCorrelation;
    set(th, 'UserData', userData);
end





