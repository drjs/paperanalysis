classdef WordClusterRow
    %WORDCLUSTERROW Class for managing words in a single row in the word
    %cloud.
    
    properties
        allWordHandles;
        % should the text be aligned from the top or bottom?
        % if the row is above centre, use bottom aligned text
        % if the row is below centre, use top aligned text
        verticalAlignment;
        % what's the left right top and bottom limit of the row?
        % measured in "blocks"
        blockSize = 0.002;
        left   = 0;
        right  = 0;
        top    = 0;
        bottom = 0;
        % how much padding to give each word (in blocks)
        marginLR = 3;
        marginTB = 0;
        % where is the row currently centred
        refPosX = 0;
        refPosY = 0;
    end
    
    methods
        function this = WordClusterRow(centreWordHandle, alignment, refX, refY)
            this.verticalAlignment = alignment;
            this.refPosX = refX;
            this.refPosY = refY;
            this.allWordHandles = centreWordHandle;
            % place centre word in centre
            this.placeWordAtLocation(centreWordHandle, ...
                this.refPosX, this.refPosY, 'center', this.verticalAlignment);
            % recalculate left, right, top and bottom extent of the row.
            this = this.recalculateLimits();
        end
        
        function this = addWordLeft(this, newWordHandle)
            % place a new word on the left side of the row.
            % save handle into list
            this.allWordHandles = [newWordHandle, this.allWordHandles];
            % add to row
            this.placeWordAtLocation(newWordHandle, ...
                this.left, this.refPosY, 'right', this.verticalAlignment);
            % recalculate limits
            this = this.recalculateLimits();
            % recentre the row
            this = this.reAlignRow();
        end
        
        function this = addWordRight(this, newWordHandle)
            % place a new word on the right side of the row.
            % save handle into list
            this.allWordHandles = [this.allWordHandles, newWordHandle];
            % add to row
            this.placeWordAtLocation(newWordHandle, ...
                this.right, this.refPosY, 'left', this.verticalAlignment);
            % recalculate limits
            this = this.recalculateLimits();
            % recentre the row
            this = this.reAlignRow();
        end
        
        function tf = isFull(this)
            tf = numel(this.allWordHandles) > 2;
            tf = tf || (this.right - this.left) > 0.3;
            tf = false;
        end
        
        function width = getWidth(this)
            width = this.right - this.left;
        end
        
        function this = shiftAllWords(this, dX, dY)
            % shifts the row centre by the given amount.
            % +x shifts right, -x shifts left
            % +y shifts up, -y shifts down.
            for th = this.allWordHandles
                th.Position = [th.Position(1)+dX, th.Position(2)+dY];
            end
            % recalculate centre and limits.
            this = this.recalculateLimits();
        end
        
        function this = respaceWordsInRow(this)
            % find centre aligned word
            for centreWordIdx = 1:numel(this.allWordHandles)
                if strcmp(this.allWordHandles(centreWordIdx).HorizontalAlignment, 'center')
                    break;
                end
            end
            
            % reposition words to left
            for i = (centreWordIdx-1):-1:1;
                newXPos = this.allWordHandles(i+1).Extent(1);
                newXPos = this.ceilToNearest(newXPos, this.blockSize);
                newXPos = newXPos - (this.marginLR*this.blockSize);
                
                this.allWordHandles(i).Position = [newXPos, this.refPosY];
            end
            
            % reposition words to the right
            for i = (centreWordIdx+1):numel(this.allWordHandles)
                newXPos = this.allWordHandles(i-1).Extent(1) ...
                    + this.allWordHandles(i-1).Extent(3);
                newXPos = this.ceilToNearest(newXPos, this.blockSize);
                newXPos = newXPos + (this.marginLR*this.blockSize);
                
                this.allWordHandles(i).Position = [newXPos, this.refPosY];
            end
            
            % recalculate centre and limits.
            this = this.recalculateLimits();
            this = this.reAlignRow();
        end
        
        function this = repositionRowAbsolute(this, newX, newY)
            dX = newX - this.refPosX;
            dY = newY - this.refPosY;
            this = this.shiftAllWords(dX, dY);
            
            this.refPosX = newX;
            this.refPosY = newY;
        end
        
        function this = repositionRowRelative(this, dX, dY)
            this = this.shiftAllWords(dX, dY);
            
            this.refPosX = this.refPosX + dX;
            this.refPosY = this.refPosY + dY;
        end
        
    end
    
    methods (Access = private)
        function this = reAlignRow(this)
            % recentre the row so that the words are evenly spaces around
            % the centre X coordinate.
            % take L and R limits and find the midpoint
            % offset the x position of all words by midpoint
            offsetX = this.refPosX - (this.left + this.right)/2;
            this = this.shiftAllWords(offsetX, 0);
        end
        
        function this = recalculateLimits(this)
            % concatenate the Extent property of every text handle.
            extents = cat(1, this.allWordHandles.Extent);
            
            % left and bottom coords of every word are stored in extents
            % already
            this.left   = this.ceilToNearest(min(extents(:,1)), this.blockSize);
            this.bottom = this.ceilToNearest(min(extents(:,2)), this.blockSize);
            
            % calculate right and top coordiantes of every word
            R = extents(:,1) + extents(:,3);
            T = extents(:,2) + extents(:,4);
            this.right = this.ceilToNearest(max(R), this.blockSize);
            this.top   = this.ceilToNearest(max(T), this.blockSize);
            
            % add margin padding to each word.
            this.left   = this.left   - (this.marginLR*this.blockSize);
            this.bottom = this.bottom - (this.marginTB*this.blockSize);
            this.right  = this.right  + (this.marginLR*this.blockSize);
            this.top    = this.top    + (this.marginTB*this.blockSize);
            
            % rectangle('position', [this.left, this.bottom, this.right-this.left, this.top-this.bottom], 'edgecolor', 'g');
        end
        
        
        function this = placeWordAtLocation(this, wh, x, y, halign, valign)
            wh.HorizontalAlignment = halign;
            wh.VerticalAlignment   = valign;
            wh.Position            = [x y];
            % wh.Parent              = this.transformGroup;
        end
        
        function y = ceilToNearest(~, x, acc)
            % rounds value x upwards to the nearest multiple of acc, in
            % the direction away from 0.
            % so ceilToNearest(2, 5) rounds 2 upto the nearest multiple of
            % 5 which is 5.
            % ceilToNearest(-2, 5) rounds -2 to -5.
            if x < 0
                y = floor(x/acc)*acc;
            else
                y = ceil(x/acc)*acc;
            end
        end
    end
    
end

