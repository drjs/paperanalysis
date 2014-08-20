function ToyingWithXML

%% Scrape the data from the XML file
clear

A = xmlread('AbstractsEditted3.xml');
allListitems = A.getElementsByTagName('p');
raw_data = {};
for indx = 1:allListitems.getLength
    if ( ~isempty( allListitems.item(indx)))
        Element = allListitems.item(indx).getFirstChild;
        if (~isempty(Element))
            if strcmpi(Element.getClass ,'class org.apache.xerces.dom.DeferredTextImpl')
                raw_data{indx} = char(Element.getData);
            end
            if strcmpi(Element.getClass ,'class org.apache.xerces.dom.DeferredElementImpl')
                if (~isempty(Element.getFirstChild))
                    if strcmpi(Element.getFirstChild.getClass ,'class org.apache.xerces.dom.DeferredElementImpl')
                        raw_data{indx} = 'NaN';
                    else
                        raw_data{indx} = char(Element.getFirstChild.getData);
                    end
                else
                    raw_data{indx} = 'NaN';
                end
            end
        else
            raw_data{indx} = 'NaN';
        end
    else
        raw_data{indx} = 'NaN';
    end
end

clear Element indx allListitems A

%% Make the data slightly nicer

strip_newline_char  =@(s) strrep(s, char(10),' ');
data_NoNewLineChars = cellfun(strip_newline_char, raw_data, 'UniformOutput', 0);
clear raw_data strip_newline_char

strip_double_spaces =@(s) regexprep(s,'\s{2,}', ' ');
data_NoDoubleSpaces = cellfun(strip_double_spaces, data_NoNewLineChars, 'UniformOutput', 0);
clear data_NoNewLineChars strip_double_spaces

% Delete small words
L = cellfun(@length, data_NoDoubleSpaces);
data_NoDoubleSpaces(L <= 3) = [];
clear L

% Delete numerical only entries
number_of_numbers = cellfun(@sum, isstrprop(data_NoDoubleSpaces ,'digit'));
L = cellfun(@length, data_NoDoubleSpaces);
data_NoDoubleSpaces( logical(round(number_of_numbers./L))) = [];
clear number_of_numbers L

data = data_NoDoubleSpaces';
clear data_NoDoubleSpaces;

%% Construct dataset indexing

IndxPapAccpt = find(strcmp(data,'Status: Accepted'));
IndxPapTitle = IndxPapAccpt-1;
IndxCategory = find(~cellfun(@isempty, strfind(data ,'Category: ')));
IndxAuthPref = find(~cellfun(@isempty, strfind(data ,'Author''s preference:')));
IndxAuthName = IndxAuthPref +1;

%PRoBable Abstract Indexing
IndxProbAbst = setdiff(1:numel(data), ...
    [IndxPapAccpt IndxPapTitle IndxCategory IndxAuthPref IndxAuthName])';


%% Make abstracts

% Probable Abstracts data entries
ProbAbstracts = data(IndxProbAbst);

% Replace small sentences
L = cellfun(@length, ProbAbstracts);
ProbAbstracts(L <= 20) = {' '};
clear L

% Make lowercase, strip puncation
ProbAbstracts = lower(ProbAbstracts);
ProbAbstracts = strrep(ProbAbstracts,':','');
ProbAbstracts = strrep(ProbAbstracts,',','');
ProbAbstracts = strrep(ProbAbstracts,'.','');
ProbAbstracts = strrep(ProbAbstracts,'(','');
ProbAbstracts = strrep(ProbAbstracts,')','');
ProbAbstracts = strrep(ProbAbstracts,'[','');
ProbAbstracts = strrep(ProbAbstracts,']','');
ProbAbstracts = strrep(ProbAbstracts,';','');
ProbAbstracts = strrep(ProbAbstracts,'\"','');
ProbAbstracts = strrep(ProbAbstracts,'"','');
ProbAbstracts = strrep(ProbAbstracts,'?','');
ProbAbstracts = strrep(ProbAbstracts,'!','');
ProbAbstracts = strrep(ProbAbstracts,'-',' ');
ProbAbstracts = strrep(ProbAbstracts,char(39),'');

% Concatenate relevant data entries

Abstracts = {};
for i= 1:numel(IndxPapTitle)-1
    ithAbs = (find ((IndxPapTitle(i) < IndxProbAbst) & (IndxPapTitle(i+1) > IndxProbAbst )));
    Abstracts(i) = {strjoin(ProbAbstracts(ithAbs)')};
end
ithAbs = (find ((IndxPapTitle(133) < IndxProbAbst) & (IndxPapTitle(133)+10 > IndxProbAbst )));
Abstracts(133) = {strjoin(ProbAbstracts(ithAbs)')};

clear ithAbs i data ProbAbstracts

%% Build the dictionary

WholeBody = strsplit(strjoin(Abstracts));

% Delete small words
L = cellfun(@length, WholeBody);
WholeBody(L <= 3) = [];

% Make lower case
WholeBody = lower(WholeBody);

% Construct the dictionary
vocabulary = unique(WholeBody);

fileid = fopen('CommonWords100oxforddictionaries.com.txt');
Wcommon = textscan(fileid, '%s');
if fileid ~=-1
    fclose(fileid);
end
Wcommon = Wcommon{1};

vocabulary(ismember(vocabulary,Wcommon)) = [];

n = length(vocabulary);
freq = zeros(n,1);
for i=1:n
    freq(i) = nnz(ismember(WholeBody,vocabulary{i}));
end

[freq, idx] = sort(freq, 'descend');
vocabulary = vocabulary(idx);
T = table(vocabulary',freq,'VariableNames',{'Vocabulary' 'Freq'});

clear idx fileid Wcommon WholeBody freq i ans n L2 L


%% Make frequency count variants for each document/term

Top30words = vocabulary(1:30);
WordFreq = zeros(numel(IndxPapTitle),30);

% Simple counting Words / Documents
for j = 1:numel(IndxPapTitle)
    for i=1:30
        WordFreq(j,i) = nnz(ismember( strsplit(Abstracts{j}) ,Top30words{i}));
    end
end

% L2 Normalization for Words
WordFreqNorms = cellfun(@norm, num2cell(WordFreq,2));
WordFreqL2 =  WordFreq./repmat(WordFreqNorms,[1 30]);

% L2 Normalization for Documents
DocFreqNorms = cellfun(@norm, num2cell(WordFreq,1));
DocFreqL2 =  WordFreq./repmat(DocFreqNorms,[133 1]);

% TF-IDF normalization (Term Frequency. * Inverse Docum. Frequency)
TF = log( WordFreq + 1);
IDF = log( numel(IndxPapTitle) ./ (  sum( ~(WordFreq <2*eps) ) + 1) );
WordFreq_tfidf = TF .* repmat(IDF, numel(IndxPapTitle), 1);


%% Try some statistics and do naive visualizations

%% Simple rank and linear correlations plots for word terms using CORR

figure(1);
subplot(1,2,1)
makeCorrelationPlot(WordFreq,'Pearson',Top30words);
title({'Spearman (rank) correlations between Top 30 terms' 'Word Counts'});
subplot(1,2,2)
makeCorrelationPlot(WordFreq,'Spearman',Top30words); 
title({'Pearson (linear) correlations between Top 30 terms' 'Word Counts'});

figure(2);
subplot(1,2,1)
makeCorrelationPlot(WordFreqL2,'Pearson',Top30words);
title({'Spearman (rank) correlations between Top 30 terms' 'Word Freq. L2 normalized'});
subplot(1,2,2)
makeCorrelationPlot(WordFreqL2,'Spearman',Top30words); 
title({'Pearson (linear) correlations between Top 30 terms' 'Word Freq. L2 normalized'});

figure(3);
subplot(1,2,1)
makeCorrelationPlot(WordFreq_tfidf,'Pearson',Top30words);
title({'Spearman (rank) correlations between Top 30 terms' 'Word Freq. TFIDF'});
subplot(1,2,2)
makeCorrelationPlot(WordFreq_tfidf,'Spearman',Top30words); 
title({'Pearson (linear) correlations between Top 30 terms' 'Word Freq. TFIDF'});

%% Simple rank and linear correlations plots for documents using CORR

figure(4)
subplot(1,2,1);
Corr_Spr = corr(WordFreq','type','spearman');
surf( (Corr_Spr)); axis square; view([0 90])
xlim([1 size(Corr_Spr,1)]); ylim([1 size(Corr_Spr,1)]);
xlabel('Document Index'); ylabel('Document Index');
title('Spearman (rank) correlations between the documents'); shading flat

subplot(1,2,2);
Corr_Pea = corr(WordFreq','type','pearson');
surf( (Corr_Pea)); axis square; view([0 90])
xlim([1 size(Corr_Pea,1)]); ylim([1 size(Corr_Pea,1)]);
xlabel('Document Index'); ylabel('Document Index');
title('Pearson (linear) correlations between the documents'); shading flat

%% Simple linkage plots for words using LINKAGE

tree = linkage(WordFreqL2','average','cosine');
D = pdist(WordFreqL2','cosine');
leafOrder = optimalleaforder(tree,D);

figure(5)
dendrogram(tree,'Reorder',leafOrder,'Labels',Top30words,'Orientation','left')


tree = linkage(WordFreq_tfidf','average','cosine');
D = pdist(WordFreq_tfidf','cosine');
leafOrder = optimalleaforder(tree,D);

figure(6)
dendrogram(tree,'Reorder',leafOrder,'Labels',Top30words,'Orientation','left')


% Finding the number of components using FITGMDIST and PRINCOMP
[pca_loadings,pca_scores,pca_lambdas] = princomp(WordFreq');

    function  makeCorrelationPlot(MATRIX,TYPE,LABELS)
        Corr_Spr = corr(MATRIX,'type',TYPE);
        surf( (Corr_Spr)); 
        axis square;  view([0 90])
        xlim([1 size(Corr_Spr,1)]); ylim([1 size(Corr_Spr,1)]);       
        shading flat;
        set(gca,'Xtick',1:size(Corr_Spr,1),'XTickLabel',LABELS,'XTickLabelRotation',45);
        set(gca,'Ytick',1:size(Corr_Spr,1),'YTickLabel',LABELS,'YTickLabelRotation',0);
    end


end

