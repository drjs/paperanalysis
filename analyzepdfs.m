 %% Analyzes PDF files in given folder for list of key words
 function pretty=analyzepdfs()
    %folder = [pwd '\papers'];
    %folder = '\\mathworks\marketing\Education\SharePoint_Big\ConferenceProceedings\SEFI2014\papers';
    folder = 'h:\Documents\projects\2014_SEFI\papers';
    keywords = {'MATLAB','Simulink','CDIO','PBL','Project.?Based Learning','Problem.?Based Learning'};
    outfile = 'results.html';
    % load all PDF files as text into workspace. Attention: Can be memory
    % intensive. ALLTEXTS is a table with variables FILENAME and TEXT
    alltexts = loadpdftext(folder);
    % analyze all texts. RESULTS is a table with variables FILENAME and one boolean for
    % each keyword. RESULTS will only give back FILENAME with at least one hit.
    results = analyzetext(alltexts,keywords);
    % pretty print output to HTML with hyperlinks to the PDF files.
    pretty=prettyprint(results);
end

function alltexts = loadpdftext(folder)
    pdffiles = dir([folder filesep '*.pdf']);
    texts = {};
    for afile = {pdffiles.name}
        eval(['!pdftotext "' folder filesep afile{1} '"'])
        [~,basename,~] = fileparts(afile{1});
        texts = [texts, fileread([folder filesep basename '.txt'])];
    end
    alltexts = table({pdffiles.name}', texts','VariableNames',{'filename','text'});
end

function results=analyzetext(alltexts, keywords)
    results = table(alltexts.filename,'VariableNames',{'filename'});
    for keyword = keywords
        variable = regexprep(keyword{1}, '\\.', '');
        findings = cellfun(@length,regexp(alltexts.text,keyword,'start','ignorecase'));
        results = [results array2table(findings,'VariableNames',matlab.lang.makeValidName({variable}))];
    end
end

function pretty=prettyprint(results)
    pretty=results;
    foo=repmat(results.filename',2,1);
    bar=sprintf('<a href="%s">%s</a>\n',foo{:});
    baz=strsplit(bar,'\n')';
    pretty.filename = baz(1:end-1);
    pretty=pretty(logical(max(pretty{:,2:end},[],2)),:);
end

