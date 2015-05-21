function [allWords, docTitle] = readOnePDFFile(obj, filename)
%PARSEONEPDFFILE Parses a pdf file and returns its title and a
%cell array containing all words in the text file (one cell per word)

% get document title from filename
[path, docTitle, ~] = fileparts(filename);

% save converted pdf to temp drive
tempPlainTextFile = [tempname '.txt'];
% converter is buggy and does not like output files with spaces in. If this
% contains a space then we have to write to the folder where the pdf is
if any(isspace(tempPlainTextFile))
    tempPlainTextFile = fullfile(path,[docTitle '.txt']);
    % call utility to convert pdf
    eval(['!', obj.pdfConverter, ' "', filename, '" ']);
else
    eval(['!', obj.pdfConverter, ' "', filename, '" "', tempPlainTextFile, '"']);
end

% parse text file.
allWords = obj.readOneTextFile(tempPlainTextFile);
delete(tempPlainTextFile);
end

