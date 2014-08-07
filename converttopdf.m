% this code does not work yet.

NET.addAssembly('microsoft.office.interop.word');
wordApp = Microsoft.Office.Interop.Word.ApplicationClass;
wordDoc = wordApp.Documents;
mydoc = wordDoc.Open('h:\Documents\projects\2014_SEFI\papers\SEFI2014_0002_final.doc')
%pdfdoc = mydoc.ExportAsFixedFormat('h:\Documents\projects\2014_SEFI\papers\SEFI2014_0002_final.doc', 17)
outfile = 'h:\Documents\projects\2014_SEFI\papers\SEFI2014_0002_final.doc';
mydoc.ExportAsFixedFormat(0, outFile, 0, false, false)

methodsview('Microsoft.Office.Interop.Word.DocumentClass')