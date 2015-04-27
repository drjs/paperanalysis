fid = fopen(fullfile('@ParseFiles','CommonWords.txt'), 'r');
wCommon = textscan(fid, '%s');
fclose(fid);

wCommon = categorical(wCommon{1});

save(fullfile('@ParseFiles','CommonWords.mat'), 'wCommon');