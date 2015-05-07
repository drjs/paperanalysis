function StartAnalysis()


testfiles = dir('testdata');
testfiles = {testfiles.name};
testfiles = {testfiles{3:end}}';


docparser = ParseFiles(testfiles, 'TestProject');
docparser.run();
% generateWordCloud(docparser, 100);
generateSemanticSurface(docparser, 100);
    
end

