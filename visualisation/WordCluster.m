classdef WordCluster
    %WORDCLOUD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        wordRows;
        centreX;
        centreY;
    end
    
    methods
        function this = WordCluster(centreWordHandle, x, y)
            this.wordRows = WordClusterRow(centreWordHandle, 'middle', x, y);
            this.centreX  = x;
            this.centreY  = y;
        end
        
        function this = addWords(this, wordHandles, correlationToCentre)
            % sort words according to how correlated they are to the centre
            [correlationToCentre, sortOrderIdx] = sort(correlationToCentre, 'descend');
            wordHandles = wordHandles(sortOrderIdx);
            % small clusters don't quite follow the same build pattern so
            % do those first proceedurally
            if numel(wordHandles) > 6;
                this = this.addFirst7Words(wordHandles(1:6));
            else
                this = this.addFirst7Words(wordHandles);
            end
            
            % start in the top row. Add a word to the right hand side
            % move down to next row add next word.
            % until adding to the right on the bottom row.
            
            % start in the bottom row add words to the left
            % move up to next row and add word to the left
            
            % when it gets back to where it started...
            % if the outer row has 3 words in
            %make a new outer row and add the new word
            
        end
        
        function this = addFirst7Words(this, wordHandles)
            % create rows to add words to.
            % add words to outer 2 rows first until 4 words are placed
            % add up to 2 words to the middle row.
            
            % sort words by length
            % find length of each word in words
            wordLengths = arrayfun(@(w) size(w.String,2), wordHandles);
            [~,sortedIdx] = sort(wordLengths);
            wordHandles = wordHandles(sortedIdx);
            
            %randomly start at the top or bottom
            isAtTop = logical(round(rand(1)));
            
            % if there are 2 or more words to add, we need 2 rows
            if numel(wordHandles) > 1
                this = this.addRowAbove(wordHandles(1));
                this = this.addRowBelow(wordHandles(2));
                wordHandles(1:2) = [];
            else
                % if there's only one word to add, put it randomly up or
                % down then stop processing more words.
                if isAtTop
                    this = this.addRowAbove(wordHandles);
                else
                    this = this.addRowBelow(wordHandles);
                end
            end
            
            switch numel(wordHandles)
                case 1
                    if isAtTop
                        this.wordRows(end) = ...
                            this.wordRows(end).addWordRight(wordHandles(1));
                    else
                        this.wordRows(1) = ...
                        this.wordRows(1).addWordRight(wordHandles(1));
                    end
                case {2, 3, 4}
                    this.wordRows(end) = ...
                        this.wordRows(end).addWordLeft(wordHandles(1));
                    this.wordRows(1) = ...
                        this.wordRows(1).addWordLeft(wordHandles(2));
                    wordHandles(1:2) = [];
            end
            
            % if there are any remaining words put them in the middle row
            switch numel(wordHandles)
                case 1
                    if isAtTop
                        this.wordRows(2) = this.wordRows(2).addWordLeft(wordHandles(1));
                    else
                        this.wordRows(2) = this.wordRows(2).addWordRight(wordHandles(1));
                    end
                case 2
                    this.wordRows(2) = this.wordRows(2).addWordRight(wordHandles(2));
                    this.wordRows(2) = this.wordRows(2).addWordLeft(wordHandles(1));
            end
        end
        
        function this = addRowAbove(this, word)
            lowerEdge = this.wordRows(end).top;
            line([0 1], [lowerEdge lowerEdge])
            this.wordRows = [this.wordRows, ...
                WordClusterRow(word, 'bottom', this.centreX, lowerEdge)];
        end
        
        function this = addRowBelow(this, word)
            upperEdge = this.wordRows(1).bottom;
            line([0 1], [upperEdge upperEdge])
            this.wordRows = [ ...
                WordClusterRow(word, 'top', this.centreX, upperEdge), ...
                this.wordRows];
        end
        
        
    end
    
end

