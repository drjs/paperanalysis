function [allWords, docTitle] = parseOnePDFFile(filename, pdfParserLocation)
%PARSEONEPDFFILE Parses a pdf file and returns its title and a
%cell array containing all words in the text file (one cell per word)

% get document title from filename
[~, docTitle] = fileparts(filename);

% save converted pdf to temp drive
tempPlainTextFile = [tempname '.txt'];
% call utility to convert pdf
eval(['!', pdfParserLocation, ' "', filename, '" "', tempPlainTextFile, '"']);

% parse text file.
allWords = parseOneTextFile(tempPlainTextFile);
delete(tempPlainTextFile);
end

