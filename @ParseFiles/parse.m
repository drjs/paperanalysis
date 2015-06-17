function obj = parse(obj)

% check the data has not already been parsed
if exist(fullfile(obj.projectFolder, 'ParsedWordData.mat'), 'file')
    olddata = load(fullfile(obj.projectFolder, 'ParsedWordData.mat'));
    % if the cached file list is different to the current one
    if isequal(sort(olddata.obj.fileList), sort(obj.fileList))
        % copy useful data from saved parser to the current one
        obj.documentTitles = olddata.obj.documentTitles;
        obj.normalisedWordCounts = olddata.obj.normalisedWordCounts;
        obj.uniqueWords = olddata.obj.uniqueWords;
        obj.wordCounts = olddata.obj.wordCounts;
        return;
    end
    % otherwise reparse files
end

numFiles = numel(obj.fileList);

% get list of common words
commonWords = load('CommonWords.mat');
commonWords = commonWords.commonWords;

% for each file, get the file's title and the location to save the parsed data
[~, obj.documentTitles, fileExtensions] = cellfun(@fileparts, obj.fileList, 'UniformOutput', false);
parsedFileList = fullfile(obj.projectFolder, strcat(obj.documentTitles, '.mat'));

% if there are pdf files to parse, locate the pdf to text converter
canWriteToTempDir = true;
if ismember('.pdf', fileExtensions)
    obj.locatePDFConverter();
    % check if temp dir contains spaces, if not we can save data to temp drive.
    if any(isspace(tempdir))
        % otherwise we need to write to the same folder as the source file
        canWriteToTempDir = false;
    end
end

% if there are doc files to parse, open up MS Word
containsDoc = false;
if any(ismember({'.doc', '.docx'}, fileExtensions))
    containsDoc = true;
    try
        obj.wordApplication = actxserver('Word.Application');
    catch exc
        error('Could not open Microsoft Word to scan doc file');
    end
end

completeWordList = [];
emptyFiles = false(1,numFiles);

disp('Mapping files');

for fileIndex = 1:numFiles
    allWords = obj.readKeywordsAndCountsFromFile(...
        obj.fileList{fileIndex}, ...
        fileExtensions{fileIndex}, ...
        parsedFileList{fileIndex}, ...
        commonWords, ...
        canWriteToTempDir);
    completeWordList = [completeWordList; allWords];
    
    fprintf('Parsed %s\n', obj.fileList{fileIndex});    
    % if the file was empty, flag it as empty to avoid any errors later.
    if(isempty(allWords))
        emptyFiles(fileIndex) = true;
        fprintf('%s was empty, ignoring from project\n', obj.fileList{fileIndex});
    end
end

% close MS Word if we used it
if containsDoc
    obj.wordApplication.Quit;
end

% remove any files flagged as empty from the rest of the parsing algorithm.
if any(emptyFiles)
    obj.fileList = obj.fileList(~emptyFiles);
    parsedFileList = parsedFileList(~emptyFiles);
    obj.documentTitles = obj.documentTitles(~emptyFiles);
    numFiles = numFiles - nnz(emptyFiles);
    % if there are no files left, that's an error.
    if numFiles < 1
        error('All files were empty, check the data or choose different files');
    end
end

disp('Reducing files');

% find unique keywords for whole project
obj.uniqueWords = categories(completeWordList);
totalWordCounts = countcats(completeWordList);

% sort unique words by their popularity
[~, newOrder] = sort(totalWordCounts, 'descend');
obj.uniqueWords = obj.uniqueWords(newOrder);

% create matrix of word counts for each document
wordCounts = zeros(numel(obj.uniqueWords), numFiles);

% reorder each paper's word counts so they are the same order
% as the new unique keyword list
for fileIndex = 1:numFiles
    data = load(parsedFileList{fileIndex});
    paperWords = data.allWords;
    paperWords = setcats(paperWords, obj.uniqueWords);
    wordCounts(:,fileIndex) = countcats(paperWords);
end
% parfor does not like objects on the LHS of an assignment, so assign
% wordCounts to obj here.
obj.wordCounts = wordCounts;

obj = obj.calculateNormalisedWordFrequencies();

save(fullfile(obj.projectFolder, 'ParsedWordData.mat'), 'obj')
disp('saved parser')
end

