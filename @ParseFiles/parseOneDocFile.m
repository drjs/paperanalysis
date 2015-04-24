function [allWords, docTitle] = parseOneDocFile(obj, filename)
%PARSEONEDOCFILE Parses a Microsoft word file and returns its title and a
%cell array containing all words in the text file (one cell per word)

% get document title from filename
[~, docTitle] = fileparts(filename);

% save word doc text to temporary plain text file
tempPlainTextFile = [tempname '.txt'];
saveWordAsText(filename, tempPlainTextFile);

% scan text file.
allWords = obj.parseOneTextFile(tempPlainTextFile);
delete(tempPlainTextFile);
end

function txtFile = saveWordAsText(docFile,txtFile)
% txtFile = saveWordAsText(docFile,txtFile)
%
% Requires that Word be installed on your system.
%
% Author: Matthew Simoneau
% URL: http://www.mathworks.com/matlabcentral/fileexchange/2668-save-word-as-text

% Locate DOC-file.
if ~exist(docFile, 'file')
    error('Cannot find "%s".',docFile);
end

% Locate TXT-file.
if (nargin < 2)
    txtFile = strrep(docFile,'.doc','.txt');
else
    if ~isempty(dir(fileparts(fullfile(pwd,txtFile))))
        % Relative path.
        txtFile = fullfile(pwd,txtFile);
    end
end

% Make sure we're not overwriting an existing file.
if ~isempty(dir(txtFile))
    error('"%s" already exists.',txtFile);
end

% Open Word.
wordApplication = actxserver('Word.Application');

% Uncomment this for debugging.
%set(wordApplication,'Visible',1);

% Get a handle to the documents object.
documents = wordApplication.Documents;

% Open the Document.
d = documents.Open(docFile);

% Save it as plain text.
wdFormatText = 2;
d.SaveAs2(txtFile,wdFormatText);

% Close the document.
d.Close;

% Close Word.
wordApplication.Quit;
end
