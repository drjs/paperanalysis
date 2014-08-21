classdef WordClusterRow
    %WORDCLUSTERROW Class for managing words in a single row in the word
    %cloud.
    
    properties
        allWordHandles;
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
        centreX = 0;
        centreY = 0;
        % should the text be aligned from the top or bottom?
        % if the row is above centre, use bottom aligned text
        % if the row is below centre, use top aligned text
        alignment;
    end
    
    methods
        function this = WordClusterRow(centreWordHandle, alignment, varargin)
            if nargin == 4
                this.centreX = varargin{1};
                this.centreY = varargin{2};
            end
            
            this.alignment = alignment;
            this.allWordHandles = centreWordHandle;
            % place centre word in centre
            this.placeWordAtLocation(centreWordHandle, ...
                this.centreX, this.centreY, 'center', this.alignment);
            % recalculate left, right, top and bottom extent of the row.
            this = this.recalculateLimits();
            
            % the first word in the row is a special case when setting
            % the top and bottom limits
            extent = centreWordHandle.Extent;
            this.top = this.ceilToNearest(extent(2)+extent(4), this.blockSize) ...
                + (this.marginLR*this.blockSize);
            this.bottom = this.ceilToNearest(extent(2), this.blockSize) ...
                - (this.marginLR*this.blockSize);
        end
        
        function this = addWordLeft(this, newWordHandle)
            % save handle into list
            this.allWordHandles = [newWordHandle, this.allWordHandles];
            % add to row
            this.placeWordAtLocation(newWordHandle, ...
                this.left, this.centreY, 'right', this.alignment);
            % recalculate limits
            this = this.recalculateLimits();
            % recentre the row
            this = this.recentreRow();
        end
        
        % addWordRight
        function this = addWordRight(this, newWordHandle)
            % save handle into list
            this.allWordHandles = [this.allWordHandles, newWordHandle];
            % add to row
            this.placeWordAtLocation(newWordHandle, ...
                this.right, this.centreY, 'left', this.alignment);
            % recalculate limits
            this = this.recalculateLimits();
            % recentre the row
            this = this.recentreRow();
        end
        
        function count = getNumberOfWordsInRow(this)
            count = numel(this.allWordHandles);
        end
        
        function this = recentreRow(this)
            % recentre the row so that the words are evenly spaces around
            % the centre X coordinate.
            % take L and R limits and find the midpoint
            % offset the x position of all words by midpoint
            offsetX = this.centreX - (this.left + this.right)/2;
            this = this.shiftRow(offsetX, 0);
        end
        
        function this = shiftRow(this, dX, dY)
            % shifts the row centre by the given amount. 
            % +x shifts right, -x shifts left
            % +y shifts up -y shifts down.
            for th = this.allWordHandles
                th.Position = [th.Position(1)+dX, th.Position(2)+dY];
            end
            % recalculate centre and limits.
%             this.centreX = this.centreX + dX;
%             this.centreY = this.centreY + dY;
            this.left    = this.left + dX;
            this.right   = this.right + dX;
            this.top     = this.top + dY;
            this.bottom  = this.bottom + dY;
        end
        
        function this = repositionRow(this, newX, newY)
            dX = newX - this.centreX;
            dY = newY - this.centreY;
            this = this.shiftRow(dX, dY);
        end
        
        function this = recalculateLimits(this)
            % this will give us the position of the bottm left corner of
            % the text box, regardless of alignment
            extentL = this.allWordHandles(1).Extent;
            extentR = this.allWordHandles(end).Extent;
            
            this.left = this.ceilToNearest(extentL(1), this.blockSize);
            this.left = this.left - (this.marginLR*this.blockSize);
            
            this.right = this.ceilToNearest(extentR(1)+extentR(3), this.blockSize);
            this.right = this.right + (this.marginLR*this.blockSize);
            
            % for top and bottom margins, use max/min of current top and
            % the top of the leftest and rightest words
            topL = this.ceilToNearest(extentL(2)+extentL(4), this.blockSize) ...
                + (this.marginLR*this.blockSize);
            topR = this.ceilToNearest(extentR(2)+extentR(4), this.blockSize) ...
                + (this.marginLR*this.blockSize);
            this.top = max([topL, topR, this.top]);
            
            botL = this.ceilToNearest(extentL(2), this.blockSize) - ...
                (this.marginTB*this.blockSize);
            botR = this.ceilToNearest(extentR(2), this.blockSize) - ...
                (this.marginTB*this.blockSize);
            this.bottom = min([this.bottom, botL, botR]);
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

