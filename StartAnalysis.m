function StartAnalysis()

isjenny = true;
if isjenny
testfiles = { ...
...% 'C:\Users\owenj\matlab_workspace\paperanalysis\testdata\SEFI2014_0062_final.pdf', ...
'C:\Users\owenj\matlab_workspace\paperanalysis\testdata\SEFI2014_0029_final.txt', ...
...% 'C:\Users\owenj\matlab_workspace\paperanalysis\testdata\SEFI2014_0002_final.doc'...
}';

docparser = ParseFiles(testfiles);
docparser.runSequentially();

else
GetFilesUI();
    
end

