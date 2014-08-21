classdef WordCluster
    %WORDCLOUD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        centreRow;
        rowsAbove;
        rowsBelow;
        centreX;
        centreY;
    end
    
    methods
        function this = WordCluster(x, y, centreWordHandle)
            this.centreRow = WordClusterRow(centreWordHandle, x, y);
            this.centreX   = x;
            this.centreY   = y;
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
        
        function this = add7Words(this, wordHandles)
            % sort words by length
            % find length of each word in words
            wordLengths = arrayfun(@(w) size(w.String{:},2), wordHandles);
            [~,sortedIdx] = sort(wordLengths);
            
            % find shortest two words
            % put shortest 2 words L and R of centre.
            this.placeWordAtLocation(this, x, y, 'right', 'middle') % left word
            % of remaining words find pairings of equal length
            % put one pair on row above
            % put one pair on row below
        end
        
    end
    
end

