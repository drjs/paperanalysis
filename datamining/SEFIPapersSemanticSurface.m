%function ToyingWithXML

%% Scrape the data from the XML file
clear
close all

[wholeBody, titles, abstracts] = readSEFIXML('AbstractsEditted5.xml');

%% Build the dictionary

[uniqueKeywords, keywordFrequency] = extractKeywordsAndKeywordCount(wholeBody);

%% Make frequency count variants for each document for top N keywords

nwords = 30;
topNWords = uniqueKeywords(1:nwords);

[DocFreqL2, correlationMatrix] = extractKeywordCountAndCorrelationByDocument(topNWords, abstracts);


%% Try some statistics and do naive visualizations

% Simple rank and linear correlations plots for word terms using CORR
%{
figure(1);
subplot(1,2,1)
makeCorrelationPlot(DocFreqL2','Pearson',Top30words);
title({'Spearman (rank) correlations between Top 30 terms' 'TF-IDF L2 norm.'});
subplot(1,2,2)
makeCorrelationPlot(DocFreqL2','Spearman',Top30words); 
title({'Pearson (linear) correlations between Top 30 terms' 'TF-IDF L2 norm.'});

% Simple rank and linear correlations plots for documents using CORR

figure(4)
subplot(1,2,1);
Corr_Spr = corr(DocFreqL2,'type','spearman');
surf( (Corr_Spr)); axis square; view([0 90])
xlim([1 size(Corr_Spr,1)]); ylim([1 size(Corr_Spr,1)]);
xlabel('Document Index'); ylabel('Document Index');
title('Spearman (rank) correlations between the documents'); shading flat

subplot(1,2,2);
Corr_Pea = corr(DocFreqL2,'type','pearson');
surf( (Corr_Pea)); axis square; view([0 90])
xlim([1 size(Corr_Pea,1)]); ylim([1 size(Corr_Pea,1)]);
xlabel('Document Index'); ylabel('Document Index');
title('Pearson (linear) correlations between the documents'); shading flat
%}

%% Matrix Decompositions

% Use PCA on the X
[pca_loadings,pca_scores,pca_lambdas] = princomp(DocFreqL2','econ');

% Use NNMF on the X 
s = RandStream('mlfg6331_64'); 
opti = statset('UseSubstreams',1,'Streams',s,'Display','off');
[nnmf_U,nnmf_V]= nnmf(DocFreqL2,3,'replicates',2^11,...
                            'options',opti, 'algorithm','als');
                        
% find axis labels from NNMF_U column peaks
[m,i] = max(nnmf_U);
label = topNWords(i);
nnmf_U(i,:) = [];
w = topNWords;
w(i) = [];
[m,i] = max(nnmf_U);
label = [label; w(i)]';
clear w, nnmf_U;

%% Make surface plot
close all
[x , y ,z] = deal(  nnmf_V(1,:)',  nnmf_V(2,:)',  nnmf_V(3,:)' );
 
% Set up fittype and options.
ftype = fittype( 'lowess' );
fopts = fitoptions('Method', 'LowessFit');
fopts.Normalize = 'on';
fopts.Robust = 'LAR';
fopts.Span = 0.1818; %Changing this will make the surface rougher or smoother

% Fit model to data.
[fitresult, gof] = fit( [x, y], z, ftype, fopts );

% Plot fit with data.
h =figure(12);
h1 = plot( fitresult, [x, y], z  );
legend(h1, ['SEFI Papers Semantic Surface'], 'Document Entries', 'Location', 'NorthEast' );
set(h1, 'MarkerFaceColor',[0 0 0])
% Label axes
xlabel([label{1,1}, ' / ', label{1,2}]);
ylabel([label{2,1}, ' / ', label{2,2}]);
zlabel([label{3,1}, ' / ', label{3,2}]);
% xlabel 'education - engineers'
% ylabel 'learning - teaching - course'
% zlabel 'project - design - skills'
grid on

% Read the spell-checked titles
fileID = fopen('exp_correct.txt','r'); 
dataArray = textscan(fileID, '%s%[^\n\r]', 'Delimiter', '',  'ReturnOnError', false); 
fclose(fileID);
h.UserData = dataArray{1};

% Change the updater for the data cursor
dcm = datacursormode(h);
set(dcm,'Enable','on', 'UpdateFcn',@NewCallback);

% Make the plot square / set position 
 
set(h, 'Position', [100, 100, 1100, 649]);

view( 47.5, 26.0 ); 
zlim([ -0.00 0.3]);

% Make the made-by-MATLAB logo

L = 40*membrane(1,25);

logoax = axes('CameraPosition', [-193.4013 -265.1546  220.4819],...
    'CameraTarget',[26 26 10], ...
    'CameraUpVector',[0 0 1], ...
    'CameraViewAngle',9.5, ...
    'DataAspectRatio', [1 1 .9],...
    'Position',[0.0 0.052 .1 .1], ...
    'Visible','off', ...
    'XLim',[1 51], ...
    'YLim',[1 51], ...
    'ZLim',[-13 40], ...
    'parent',h);
s = surface(L, ...
    'EdgeColor','none', ...
    'FaceColor',[0.9 0.2 0.2], ...
    'FaceLighting','phong', ...
    'AmbientStrength',0.3, ...
    'DiffuseStrength',0.6, ... 
    'Clipping','off',...
    'BackFaceLighting','lit', ...
    'SpecularStrength',1, ...
    'SpecularColorReflectance',1, ...
    'SpecularExponent',7, ...
    'Tag','TheMathWorksLogo', ...
    'parent',logoax);
l1 = light('Position',[40 100 20], ...
    'Style','local', ...
    'Color',[0 0.8 0.8], ...
    'parent',logoax);
l2 = light('Position',[.5 -1 .4], ...
    'Color',[0.8 0.8 0], ...
    'parent',logoax);

 mTextBox = uicontrol('style','text','Position',[1 00 120 20], 'FontSize', 11);
 set(mTextBox,'String','Made by MATLAB')

%Rotate the figure
 
%   NumFra = 500;
%    v = [ linspace(47,-111,NumFra)' linspace(26,22,NumFra)' ];   %# matrix where each row specify Az/El of view
%    for i=1:size(v,1)
%        view( h.Children(4), [v(i,:)] ) 
%        drawnow
%    end

%{

 figure(12)
 subplot(2,1,1);
 plot(nnmf_U,'DisplayName','nnmf_U'); grid on; legend('Semantic Comp. 1', 'Semantic Comp. 3','Semantic Comp. 3')
 set(gca, 'Xtick',1:numel(Top30words),'XTickLabel',Top30words,'XTickLabelRotation',45); title('NNMF Semantic Insights');
 
 subplot(2,1,2);
 plot(pca_loadings(:,1:3),'DisplayName','nnmf_U'); grid on; legend('Semantic Comp. 1', 'Semantic Comp. 3','Semantic Comp. 3')
 set(gca, 'Xtick',1:numel(Top30words),'XTickLabel',Top30words,'XTickLabelRotation',45); title('LSA Semantic Insights');
 
 clear x y z ftype fopts fitresult gof h

%% Simple linkage plots for words using LINKAGE

tree_NNMF = linkage(nnmf_V','average','cosine');
D_NNMF = pdist(nnmf_V','cosine');
leafOrder = optimalleaforder(tree_NNMF,D_NNMF);
figure(5)
dendrogram(tree_NNMF,'Reorder',leafOrder); %This visualizes up to 30 points
title('NNMF generated Hierchical Clustering')

tree_PCA = linkage(pca_scores(:,1:3),'average','cosine');
D_PCA = pdist(pca_scores(:,1:3),'cosine');
leafOrder = optimalleaforder(tree_PCA,D_PCA);
figure(6)
dendrogram(tree_PCA,'Reorder',leafOrder)%This visualizes up to 30 points
title('LSA generated Hierchical Clustering')

%% k-means plots for word using KMEANS

[IDX_NNMF,C_NNMF,sumd_NNMF] = kmeans(nnmf_scores,3,'Distance','cosine');
[IDX_PCA,C_PCA,sumd_PCA] = kmeans(pca_scores(:,1:3),3,'Distance','cosine');

%end
%}