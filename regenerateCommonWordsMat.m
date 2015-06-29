% Copyright 2015 The MathWorks Inc.
%
fid = fopen(fullfile('@ParseFiles','CommonWords.txt'), 'r');
commonWords = textscan(fid, '%s');
fclose(fid);

commonWords = categorical(commonWords{1});

save(fullfile('@ParseFiles','CommonWords.mat'), 'commonWords');