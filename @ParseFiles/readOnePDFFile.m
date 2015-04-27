function [allWords, docTitle] = readOnePDFFile(obj, filename)
%PARSEONEPDFFILE Parses a pdf file and returns its title and a
%cell array containing all words in the text file (one cell per word)

% get document title from filename
[~, docTitle] = fileparts(filename);

% save converted pdf to temp drive
tempPlainTextFile = [tempname '.txt'];
% call utility to convert pdf
eval(['!', obj.pdfConverter, ' "', filename, '" "', tempPlainTextFile, '"']);

% parse text file.
allWords = obj.readOneTextFile(tempPlainTextFile);
delete(tempPlainTextFile);
end

