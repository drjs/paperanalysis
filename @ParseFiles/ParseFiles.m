classdef ParseFiles < handle
    %PARSEFILES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileList;
        projectName;
        wordCounts;
        documentTitles;
        uniqueWords;
    end
    
    properties (Access = private)
        pdfConverter=''; % utility for converting pdfs, if required
        wordApplication; % COM connection to MS Word, for converting doc files
        projectFolder;
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

