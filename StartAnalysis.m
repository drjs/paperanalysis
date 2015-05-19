function StartAnalysis()

testfiles = dir('\\mathworks\marketing\Education\SharePoint_Big\ConferenceProceedings\SEFI2014\papers');
testfiles = {testfiles.name};
testfiles = {testfiles{3:end}}';
testfiles = strcat('\\mathworks\marketing\Education\SharePoint_Big\ConferenceProceedings\SEFI2014\papers\', testfiles);

docParser = ParseFiles(testfiles, 'SEFI_2014');
docParser.parse();
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

