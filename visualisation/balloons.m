function balloons(words, wordCount, corrMat, tree)
    %BALLOONS Summary of this function goes here
    %   Detailed explanation goes here
    
    f = figure('Name', 'Balloon Race');
    axText = axes();
    
    textGroup = generateTextHandles(words, wordCount, corrMat, tree);
    [~,referenceWordIdx] = max(wordCount);
    
    % place other words on the Y axis proportionally to their relationship
    % to the reference word.
    distances = corrMat(referenceWordIdx, :);
    % max distance = 1 for close -1 for far away
    % rescale to 0 for -1 and 1 for 1
    y = (distances+1)./2;
    % reposition all the text
    arrayfun(@(th,y) set(th, 'position', [0, y]) , textGroup.Children, y'); 
    
    % make new X coordinates based on word correlation with other words
    newX = generateXPositionsFromCorrMat(corrMat, referenceWordIdx);
    
    arrayfun(@setXPositionOfText, textGroup.Children, newX);
    
    % place main reference word at the top centre
    set(textGroup.Children(referenceWordIdx), ...
        'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'center', ...
        'Position', [0.5, 1]);
    
    % add some random jitter to make it look nice
    
    
    % set(f,'CurrentAxes',axCircles);
    % circleGroup = hggroup;
    % makeCircleAroundText(textGroup.Children(1), circleGroup);
    %cellfun(@makeCircleAroundText, textGroup, 'UniformOutput', false);
    
end

function newX = generateXPositionsFromCorrMat(corrMat, referenceWordIdx)
    % find most popular words i.e. ones most correlated with others
    [~,sortedSumCorrIdx] = sort(sum(corrMat,1), 'descend');
    % remove the already placed reference word from the list
    sortedSumCorrIdx(sortedSumCorrIdx == referenceWordIdx) = [];
    
    % put 4 most popular words in their own column
    c1words = sortedSumCorrIdx(1);
    c2words = sortedSumCorrIdx(2);
    c3words = sortedSumCorrIdx(3);
    c4words = sortedSumCorrIdx(4);
    
    % for all remaining words put them in the column they're closest to
    for idx = sortedSumCorrIdx(5:end)
        columnAffinity = [0 0 0 0];
        columnAffinity(1) = sum(corrMat(c1words, idx) );
        columnAffinity(2) = sum(corrMat(c2words, idx) );
        columnAffinity(3) = sum(corrMat(c3words, idx) );
        columnAffinity(4) = sum(corrMat(c4words, idx) );
        
        [~,bestCol] = max(columnAffinity);
        switch(bestCol)
            case 1
                c1words = [c1words, idx];
            case 2
                c2words = [c2words, idx];
            case 3
                c3words = [c3words, idx];
            case 4
                c4words = [c4words, idx];
        end
    end
    newX = zeros(size(corrMat,1),1);
    newX(c1words) = 0.125;
    newX(c2words) = 0.875;
    newX(c3words) = 0.375;
    newX(c4words) = 0.625;
end

function setXPositionOfText(th, x)
    y = th.Position(2);
    th.Position = [x,y];
end

function c = makeCircle(x, y, radius, colour)
   % make a circle centred on (x,y) with given radius and colour.
   npoints = 36;
   theta = linspace(0, 2*pi, npoints+1);
   x = cos(theta).*radius+x;
   y = sin(theta).*radius+y;
   c = fill(x,y,colour);
   set(c, 'EdgeColor', colour); %, 'BackFaceLighting', 'lit');
end

function c = makeCircleAroundText(th, parent)
   x = th.Extent(1);
   y = th.Extent(2);
   r = (th.Extent(3)/2)*1.1;
   col = 1-th.Color;
   c = makeCircle(x, y, r, col);
end

