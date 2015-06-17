function [allWords, docTitle] = readOnePDFFile(obj, filename, canWriteToTempDir)
%PARSEONEPDFFILE Parses a pdf file and returns its title and a
%cell array containing all words in the text file (one cell per word)

% get document title from filename
[path, docTitle, ~] = fileparts(filename);

% converter is buggy and does not like output files with spaces in. If this
% contains a space then we have to write to the folder where the pdf is.
% save converted pdf to temp drive if possible, otherwise save in same dir
% as the source
if canWriteToTempDir
    tempPlainTextFile = [tempname '.txt'];
    eval(['!"', obj.pdfConverter, '" "', filename, '" "', tempPlainTextFile, '"']);
else
    tempPlainTextFile = fullfile(path,[docTitle '.txt']);
    % call utility to convert pdf
    eval(['!"', obj.pdfConverter, '" "', filename, '" ']);
end

% parse text file.
allWords = obj.readOneTextFile(tempPlainTextFile);
delete(tempPlainTextFile);
end

