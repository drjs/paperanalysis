function obj = runSequentially(obj)
% for each file
% get document type
% use relevant parse script to get list of words and title
% remove all words containing non alphabet characters or empties
% remove all common words
% more clever regular expression stuff?
% From word list find unique words and their count
% sort word list and counts alphabetically (use key/value store?)
% find unique keywords for whole project
% reorder each paper's word counts so they are the same order
% as the new unique keyword list

% output should be something like a 2D matrix of word counts
% one dimension indexed by project keywords
% other dimension indexed by paper title

disp('parsing files sequentially')

end
