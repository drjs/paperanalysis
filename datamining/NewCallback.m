function output_txt = NewCallback(empt,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position'); disp(pos);
handles = get(gcf,'UserData');

titleIndex = intersect( intersect( find(abs(abs(event_obj.Target.XData)-abs(pos(1)))< 0.001),...
    find(abs(abs(event_obj.Target.ZData)-abs(pos(3)))< 0.001)) , ...
    find(abs(abs(event_obj.Target.YData)-abs(pos(2)))< 0.001));

output_txt = handles{ titleIndex } ;

spaceIndeces = strfind(output_txt,' ');
% Find space index closer to the middle
[~,minIndx] = min( abs( spaceIndeces -  numel(output_txt)*0.5));

output_txt = { output_txt(1:spaceIndeces(minIndx)-1);output_txt(spaceIndeces(minIndx):end) };

%disp(pos)
% If there is a Z-coordinate in the position, display it as well
% if length(pos) > 2
%     output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
% end


