classdef WordCluster
    %WORDCLOUD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        centreWordHandle;
        centreX;
        centreY;
        subClouds= [];
    end
    
    methods
        function this = WordCluster(centreWordHandle)
            this.centreWordHandle = centreWordHandle;
            this.centreX = 0;
            this.centreY = 0;
        end
        
        function this = addWords(this, wordHandles, wordCounts, corrMat)
            if numel(wordHandles) == 7;
                this = this.add7words(wordHandles);
            end
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

