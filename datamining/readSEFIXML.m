function [allWords, titles, abstracts] = readSEFIXML(xmlfile)

A = xmlread(xmlfile);
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

abstracts = {};
for i= 1:numel(IndxPapTitle)-1
    ithAbs = (find ((IndxPapTitle(i) < IndxProbAbst) & (IndxPapTitle(i+1) > IndxProbAbst )));
    abstracts(i) = {strjoin(ProbAbstracts(ithAbs)')};
end
ithAbs = (find ((IndxPapTitle(133) < IndxProbAbst) & (IndxPapTitle(133)+10 > IndxProbAbst )));
abstracts(133) = {strjoin(ProbAbstracts(ithAbs)')};

clear ithAbs i   ProbAbstracts

Indx.IndxAuthName =IndxAuthName;
Indx.IndxAuthPref =IndxAuthPref;
Indx.IndxCategory =IndxCategory;
Indx.IndxPapAccpt =IndxPapAccpt;
Indx.IndxPapTitle =IndxPapTitle;
Indx.IndxProbAbst =IndxProbAbst;

clear IndxAuthName IndxAuthPref IndxCategory ... 
      IndxPapAccpt IndxPapTitle IndxProbAbst

%% Build the dictionary

allWords = strsplit(strjoin(abstracts));
titles = data(Indx.IndxPapTitle);


end

