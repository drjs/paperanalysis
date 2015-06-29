function h = generateSemanticSurface(parserObject, nwords)
%GENERATESEMANTICSURFACE Creates Semantic surface showing relationship
%between papers.
% 
% Author: Pantelis Hadjipantelis, Jenny Owen, Joachim Schlosser.
% Copyright 2015 The MathWorks Inc.

if nwords > size(parserObject.normalisedWordCounts, 1)
    nwords = size(parserObject.normalisedWordCounts, 1);
end
% normalisedWordCounts = parserObject.normalisedWordCounts(1:nwords,:);
topNWords = parserObject.uniqueWords(1:nwords);

[x,y,z, axisLabels] = usePCAOnData(parserObject.wordCounts(1:nwords,:), topNWords);
% [x,y,z, axisLabels] = useNNMFOnData(parserObject.wordCounts(1:nwords,:), topNWords);
 
% create figure for plot
figTitle = [parserObject.projectName, ' Semantic Surface'];
h =figure('Name', figTitle);
colordef black;
h.Color='black';

% if the curve fitting toolbox is present, add a best fit surface.
% if license('test', 'curve_fitting_toolbox') == 1
try
    [fitresult, ~] = fit( [x, y], z, 'cubicinterp' );
    % Plot fit with data.
    ax = plot( fitresult, [x, y], z  );
    %legend(ax, figTitle, 'Document Entries', 'Location', 'NorthEast' );
catch
    ax = scatter3( x, y, z  );
end

set(ax, 'MarkerFaceColor',[0 0 0])

% Label axes
xlabel(axisLabels{1});
ylabel(axisLabels{2});
zlabel(axisLabels{3});
% grid on

% Read the spell-checked titles
h.UserData = parserObject.documentTitles;

% Change the updater for the data cursor
dcm = datacursormode(h);
set(dcm, 'Enable', 'on', 'UpdateFcn', @dataCursorCallback);

% Light
lighting gouraud;
material shiny;
shading interp;
li = light('Position',[200 100 10000],'Style','local');

% add logo
WordCloud.addMWLogo(h);

end

function output_txt = dataCursorCallback(~, event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
handles = get(gcf,'UserData');

titleIndex = intersect( intersect( find(abs(abs(event_obj.Target.XData)-abs(pos(1)))< 0.001),...
    find(abs(abs(event_obj.Target.ZData)-abs(pos(3)))< 0.001)) , ...
    find(abs(abs(event_obj.Target.YData)-abs(pos(2)))< 0.001));

output_txt = handles{ titleIndex } ;

end

function [x,y,z, axisLabels] = usePCAOnData(counts, words)
% Use pca on the normalised word counts
[pca_loadings,pca_scores] = pca(counts', 'NumComponents', 10);

% find axis labels from pca scores column peaks
[~,i] = max(pca_loadings);
axisLabels = words(i);

pca_loadings(i,:) = [];
tempWords = words;
tempWords(i) = [];
[~,i] = max(pca_loadings);
axisLabels = strcat(axisLabels, ' / ', tempWords(i));

% plot(pca_loadings);
% set(gca, 'xtick', 1:numel(words), 'xticklabels', words, 'xticklabelrotation', 90);

z = pca_scores(:,3);
y = pca_scores(:,2);
x = pca_scores(:,1);

end

function [x,y,z, axisLabels] = useNNMFOnData(counts, words)
% === Pantelis code ===

% Use NNMF on the normalised word counts
s = RandStream('mlfg6331_64'); 
opti = statset('UseSubstreams',1,'Streams',s,'Display','off');
[nnmf_U,nnmf_V]= nnmf(counts, 3, ...
                      'replicates',2^11,...
                      'options',opti, ...
                      'algorithm','als');
                        
% find axis labels from NNMF_U column peaks
[~,i] = max(nnmf_U);
axisLabels = words(i);

nnmf_U(i,:) = [];
tempWords = words;
tempWords(i) = [];
[~,i] = max(nnmf_U);
axisLabels = strcat(axisLabels, '/', tempWords(i));


% Make surface plot
[x , y ,z] = deal(  nnmf_V(1,:)',  nnmf_V(2,:)',  nnmf_V(3,:)' );

end

