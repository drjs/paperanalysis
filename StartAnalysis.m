function StartAnalysis()

%thedir = '\\mathworks\marketing\Education\SharePoint_Big\ConferenceProceedings\SEFI2014\papers';
thedir = 'h:\Documents\MATLAB\paperanalysis\SEFI_2014';
testfiles = dir(strcat(thedir,'\','*.doc*'));
testfiles = [testfiles; dir(strcat(thedir,'\','*.pdf'))];
testfiles = {testfiles.name};
testfiles = {testfiles{3:end}}';
testfiles = strcat(thedir, '\', testfiles);

docParser = ParseFiles(testfiles, 'SEFI_2014');
docParser.parse();
save docParser;
WordCloudEditor('parser', docParser);

% testfiles = dir('testdata');
% testfiles = {testfiles.name};
% testfiles = {testfiles{3:end}}';
% testfiles = cellfun(@(x) fullfile(pwd, 'testdata', x), testfiles, 'UniformOutput', false);
% 
% docparser = ParseFiles(testfiles, 'TestProject');
% docparser.run();
% rmdir(fullfile(pwd, 'TestProject'), 's');
% generateWordCloud(docparser, 100);
% generateSemanticSurface(docparser, 100);
    
end

