function [allWords, varargout] = parseOneTextFile(obj, filename)
%PARSEONETEXTFILE Parses a single text file and returns its title and a
%cell array containing all words in the text file (one cell per word).
% allWords = parseOneTextFile(__) returns a cell array of all the words in the txt
% file
% [allWords, docTitle] = parseOneTextFile(filename) returns the title and
% the words.

fid = fopen(filename, 'r');

% read data in blocks
blocksize = 500;
count = 0;
while ~feof(fid)
    count = count + 1;
    words(count) = textscan(fid, '%s', blocksize, 'MultipleDelimsAsOne', true, 'Delimiter', '\b \t\\;:.,\n!?-[]{}~()"@&%+');
end
fclose(fid);
allWords = vertcat(words{:});

if nargout == 2
    % output document title as the file name without path or file extension
    [~, varargout{1}] = fileparts(filename);
end
end

