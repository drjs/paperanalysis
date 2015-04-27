function allWords = readKeywordsAndCountsFromPaper(obj, fileToRead, fileToReadExtension, fileToSaveWordDataInto, commonWords)

% check file has not already been parsed and saved
if exist(fileToSaveWordDataInto, 'file')
    % if there is a preparsed version of this paper in the project
    % folder then load that instead
    data = load(fileToSaveWordDataInto);
    allWords = data.allWords;
else
    
    % use relevant parse script to get list of words and title
    switch fileToReadExtension
        case '.txt'
            [words, paperTitle] = obj.readOneTextFile(fileToRead);
        case '.doc'
            [words, paperTitle] = obj.readOneDocFile(fileToRead);
        case '.docx'
            [words, paperTitle] = obj.readOneDocFile(fileToRead);
        case '.pdf'
            [words, paperTitle] = obj.readOnePDFFile(fileToRead);
        otherwise
            error('Found unparsable file "%s", aborting.', fileToRead);
    end
    % find short words, and words containing numbers or characters
    validWordIdx = cellfun(@checkWordIsValid, words);
    % remove all invalid words and make everything lower case.
    words = lower(words(validWordIdx));
    
    % convert complete word list to categorical array
    allWords = categorical(words);
    
    % remove common words
    allWords = removecats(allWords, categories(commonWords));
    allWords = allWords(~isundefined(allWords));
    
    % from categorical get list of unique keywords and their counts
    keywordCount = countcats(allWords);
    
    % saved parsed data into a mat fileia
    %     save(parsedDataSaveFile, 'uniqueKeywords', 'keywordCount', 'paperTitle');
    save(fileToSaveWordDataInto, 'allWords', 'keywordCount', 'paperTitle');
end
end

function isValid = checkWordIsValid(oldWord)
% === (slightly modified) code from Pantelis's datamining =========

isValid = false;
% remove short or empty words
if length(oldWord) > 3
    % remove all words containing non alphabet characters or empties
    if isempty(regexpi(oldWord, '[^a-z]', 'once'));
        % more clever regular expression stuff?
        isValid = true;
    end
end
end




