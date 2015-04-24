function obj = runSequentially(obj)
disp('parsing files sequentially'); % For testing

numFiles = numel(obj.fileList);

% get list of common words
fid = fopen('CommonWords.txt');
Wcommon = textscan(fid, '%s');
if fid ~=-1
    fclose(fid);
end
Wcommon = Wcommon{1};

% for each file
for fileIndex = 1:numFiles
    % get document type
    [~,~,ext] = fileparts(obj.fileList{fileIndex});
    % use relevant parse script to get list of words and title
    switch ext
        case '.txt'
            [words, paperTitle] = obj.parseOneTextFile(obj.fileList{fileIndex});
        case '.doc'
            [words, paperTitle] = obj.parseOneDocFile(obj.fileList{fileIndex});
        case '.pdf'
            [words, paperTitle] = obj.parseOnePDFFile(obj.fileList{fileIndex});
        otherwise
            error('Found unparsable file "%s", aborting.', obj.fileList{fileIndex});
    end
    
    validWordIdx = cellfun(@checkWordIsValid, words);
    words = lower(words(validWordIdx));
       
    % Construct list of unique keywords
    [uniqueKeywords, ~, idx] = unique(words);
    
    % find word count for each unique keyword
    keywordCount = zeros(numel(uniqueKeywords, 1));
    for i = 1:numel(uniqueKeywords)
        matches  = ~logical(idx - i);
        keywordCount(i) = nnz(matches);
    end
    
    % sort word list and counts alphabetically
    [uniqueKeywords, idx] = sort(uniqueKeywords);
    keywordCount = keywordCount(idx);
end % stop looping through all files

% find unique keywords for whole project
% reorder each paper's word counts so they are the same order
% as the new unique keyword list

% output should be something like a 2D matrix of word counts
% one dimension indexed by project keywords
% other dimension indexed by paper title


function isValid = checkWordIsValid(oldWord)
    % === (slightly modified) code from Pantelis's datamining =========
    
    isValid = false;
    % remove short or empty words
    if length(oldWord) > 3
        % remove all words containing non alphabet characters or empties
        if isempty(regexpi(oldWord, '[^a-z]', 'once'));
            % Check if word appears in common word list
            if ~ismember(lower(oldWord),Wcommon)
                % more clever regular expression stuff?
                isValid = true;
            end
        end
    end
end


end

