classdef ParseFiles < handle
    %PARSEFILES Takes a cell array of file names and counts the number of
    %times each unique word appears.
    % FILELIST list of files to parse. If there is only one file it can be
    % a single string. Otherwise store the file list in a vertical cell
    % array. 
    % This will ignore any words containing non-alphabet characters (e.g.
    % "don't". It also filters out any words with 3 or fewer letters.
    % PROJECTNAME the name you want to give the project. This is used for
    % caching parsed data locally into mat files.
    % 
    % Example:
    % p = ParseFiles('data\mydoc.txt', 'myProject')
    % p = ParseFiles({'data\mydoc1.txt'; data\mydoc2.txt'}, 'myProject');
    %
    % See also:
    % GetFileUI
    %
    % Author: Jenny Owen
    % Copyright: MathWorks 2015
    
    
    properties
        fileList;
        projectName;
        documentTitles;
        uniqueWords;
        wordCounts;
        normalisedWordCounts;
        projectFolder;
    end
    
    properties (Access = private)
        pdfConverter=''; % utility for converting pdfs, if required
        wordApplication; % COM connection to MS Word, for converting doc files
    end
    
    methods
        function obj = ParseFiles(fileList, projectName)
            if ~iscell(fileList)
                fileList = {fileList};
            end
            obj.fileList = fileList;
            obj.projectName = projectName;
            
            % create project folder (if there isn't one)
            obj.projectFolder = fullfile(pwd, obj.projectName);
            if ~exist(obj.projectFolder, 'dir')
                mkdir(obj.projectFolder);
            end

        end
        
    end
    
end

