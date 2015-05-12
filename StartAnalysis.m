function StartAnalysis()

testfiles = dir('\\mathworks\marketing\Education\SharePoint_Big\ConferenceProceedings\SEFI2014\papers');
testfiles = {testfiles.name};
testfiles = {testfiles{3:end}}';


docParser = ParseFiles(testfiles, 'SEFI2014');
docParser.run();
WordCloudEditor('parser', docParser);
% fac = WordCloud.WordCloudFactory();
% fac.buildCloud(docParser, 100);

% testfiles = dir('testdata');
% testfiles = {testfiles.name};
% testfiles = {testfiles{3:end}}';
% 
% 
% docparser = ParseFiles(testfiles, 'TestProject');
% docparser.run();
% % generateWordCloud(docparser, 100);
% generateSemanticSurface(docparser, 100);
    
end

