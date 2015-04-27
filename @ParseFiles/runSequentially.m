function obj = runSequentially(obj)
disp('parsing files sequentially'); % For testing

numFiles = numel(obj.fileList);

% get list of common words
commonWords = load('CommonWords.mat');
commonWords = commonWords.commonWords;

% for each file, get the file's title and the location to save the parsed
% data
[~, obj.documentTitles, fileExtensions] = cellfun(@fileparts, obj.fileList, 'UniformOutput', false);
parsedFileList = fullfile(obj.projectFolder, strcat(obj.documentTitles, '.mat'));

% if there are pdf files to parse, locate the pdf to text converter
if ismember('.pdf', fileExtensions)
    obj.locatePDFConverter();
end

% if there are doc files to parse, open up MS Word
containsDoc = false;
if any(ismember({'.doc', '.docx'}, fileExtensions))
    containsDoc = true;
    obj.wordApplication = actxserver('Word.Application');
end

completeWordList = [];

for fileIndex = 1:numFiles
    obj.fileList{fileIndex};
    allWords = obj.readKeywordsAndCountsFromPaper(...
        obj.fileList{fileIndex}, ...
        fileExtensions{fileIndex}, ...
        parsedFileList{fileIndex}, ...
        commonWords);   
    completeWordList = [completeWordList; allWords];
end

% close MS Word if we used it
if containsDoc
    obj.wordApplication.Quit;
end

% find unique keywords for whole project
obj.uniqueWords = categories(completeWordList);
% totalWordCounts = countcats(completeWordList);

% create matrix of word counts for each document
obj.wordCounts = zeros(numel(obj.uniqueWords), numFiles);

% reorder each paper's word counts so they are the same order
% as the new unique keyword list
for fileIndex = 1:numFiles
    data = load(parsedFileList{fileIndex});
    paperWords = data.allWords;
    paperWords = setcats(paperWords, uniqueWords);
    obj.wordCounts(:,fileIndex) = countcats(paperWords);
end


end

