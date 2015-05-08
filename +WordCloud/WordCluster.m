classdef WordCluster
    %WORDCLOUD A single cluster of words within a WordCloud
    
    properties
        textHandles;
        numWords;
        wordRows;
        centreX;
        centreY;
        % the left right top and bottom extent of this word cluster.
        left   = 0;
        right  = 0;
        top    = 0;
        bottom = 0;
        % the ideal width:height ratio of a word cluster
        widthHeightRatio = 3/1;
    end
    
    methods
        function this = WordCluster(centreWordHandle, x, y)
            this.textHandles = centreWordHandle;
            this.wordRows    = WordCloud.WordClusterRow(centreWordHandle, 'middle', x, y);
            this.centreX     = x;
            this.centreY     = y;
            this.numWords    = numel(this.textHandles);
            this = recalculateLimits(this);
        end
        
        function this = addWords(this, wordHandles, correlationToCentre)
            % sort words according to how correlated they are to the centre
            [~, sortOrderIdx] = sort(correlationToCentre, 'descend');
            wordHandles = wordHandles(sortOrderIdx);
            this.textHandles = [this.textHandles, wordHandles];
            wordAt = 1; % current word to add to cluster
            
            while wordAt <= numel(wordHandles)
                % if bottom row is full and there's at least one more word,
                % create a new row underneath and add next word
                if(this.isRowFull(1) && wordAt <= numel(wordHandles))
                    this = addRowBelow(this, wordHandles(wordAt));
                    wordAt = wordAt + 1;
                end
                
                % start in the bottom row add words to the left
                % move up to next row and add word to the left
                [this, wordAt] = this.addWordsBottomLToTopL(wordAt, wordHandles);
                
                
                % if top row is full and there's at least one more word,
                % create a new row above and add next word
                if(this.isRowFull(numel(this.wordRows)) && ...
                        wordAt <= numel(wordHandles))
                    this = addRowAbove(this, wordHandles(wordAt));
                    wordAt = wordAt + 1;
                end
                
                % start in the top row. Add a word to the right hand side
                % move down to next row add next word.
                % until adding to the right on the bottom row.
                [this, wordAt] = this.addWordsTopRToBottomR(wordAt, wordHandles);
                
            end
            this = respaceRowsVertically(this);
            this.numWords = numel(this.textHandles);
        end
        
        function this = recentreCluster(this, newX, newY)
            dX = newX - this.centreX;
            dY = newY - this.centreY;
            for i = 1:numel(this.wordRows)
                this.wordRows(i) = this.wordRows(i).repositionRowRelative(dX, dY);
            end
            this = recalculateLimits(this);
            this.centreX = newX;
            this.centreY = newY;
        end
        
        function this = reColourCluster(this, newColours)
            if size(newColours, 1) == 1
                % if there is only 1 colour in newColours, make all words the
                % same colour.
                for i = 1:numel(this.textHandles)
                    this.textHandles(i).Color = newColours;
                end
            else
                % otherwise recolour all words the corresponding colour
                for i = 1:numel(this.textHandles)
                    this.textHandles(i).Color = newColours(i,:);
                end
            end
        end
        
        function this = rescaleText(this, newScaleFactor)
            resizeFcn = @(h)set(h, 'FontSize', ...
                h.UserData.wordCount*newScaleFactor);
%             this.textHandles = arrayfun(resizeFcn, this.textHandles);
            arrayfun(resizeFcn, this.textHandles);
            
            this = this.respaceRowsHorizontally();
            this = this.respaceRowsVertically();
        end
        
        function this = recalculateLimits(this)
            this.left   = min([this.wordRows.left]);
            this.right  = max([this.wordRows.right]);
            this.top    = max([this.wordRows.top]);
            this.bottom = min([this.wordRows.bottom]);
            % rectangle('position', [this.left, this.bottom, this.right-this.left, this.top-this.bottom], 'edgecolor', 'r');
        end
    end
    
    methods (Access = private)
        function [this, wordAt] = addWordsBottomLToTopL(this, wordAt, wordHandles)
            r = 1;
            while (r <= numel(this.wordRows)) && (wordAt <= numel(wordHandles))
                % if there is space in the row, add another word
                if(~this.isRowFull(r))
                    this.wordRows(r) = ...
                        this.wordRows(r).addWordLeft(wordHandles(wordAt));
                    wordAt = wordAt + 1;
                end
                r = r + 1;
            end
        end
        
        function [this, wordAt] = addWordsTopRToBottomR(this, wordAt, wordHandles)
            r = numel(this.wordRows);
            while (r > 0) && (wordAt <= numel(wordHandles))
                if(~this.isRowFull(r))
                    this.wordRows(r) = ...
                        this.wordRows(r).addWordRight(wordHandles(wordAt));
                    wordAt = wordAt + 1;
                end
                r = r-1;
            end
        end
        
        function isfull = isRowFull(this, r)
            clusterHeight = this.top - this.bottom;
            % if the width of row r exceeds ideal ratio for current height
            % then it is full
            isfull = this.wordRows(r).getWidth > clusterHeight * this.widthHeightRatio;
        end
        
        function this = addRowAbove(this, starterWord)
            lowerEdge = this.wordRows(end).top;
            this.wordRows = [this.wordRows, ...
                WordCloud.WordClusterRow(starterWord, 'bottom', this.centreX, lowerEdge)];
        end
        
        function this = addRowBelow(this, starterWord)
            upperEdge = this.wordRows(1).bottom;
            this.wordRows = [ ...
                WordCloud.WordClusterRow(starterWord, 'top', this.centreX, upperEdge), ...
                this.wordRows];
        end
        
        function this = respaceRowsVertically(this)
            % find the centre row, this is the one that's 'middle' aligned
            for middleRow = 1:numel(this.wordRows)
                if strcmp(this.wordRows(middleRow).verticalAlignment, 'middle');
                    % recalculate middle row limits
                    this.wordRows(middleRow) = ...
                        this.wordRows(middleRow).repositionRowRelative(0,0);
                    break
                end
            end
            % for all above the centre row set the centre to the top limit
            % of line below
            for r = (middleRow+1):numel(this.wordRows)
                %line(xlim, [this.wordRows(r-1).top, this.wordRows(r-1).top]);
                dY = this.wordRows(r-1).top - this.wordRows(r).refPosY;
                this.wordRows(r) = this.wordRows(r).repositionRowRelative(0, dY);
            end
            for r = (middleRow-1):-1:1
                dY = this.wordRows(r+1).bottom - this.wordRows(r).refPosY;
                this.wordRows(r) = this.wordRows(r).repositionRowRelative(0, dY);
            end
            this = this.recalculateLimits();
        end
        
        function this = respaceRowsHorizontally(this)
            for r = 1:numel(this.wordRows)
                this.wordRows(r) = this.wordRows(r).respaceWordsInRow();
            end
            this = this.recalculateLimits();
        end
    end
    
end

