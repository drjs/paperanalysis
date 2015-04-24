classdef ParseFiles < handle
    %PARSEFILES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileList;
        pdfConverter='';
    end
    
    methods
        function obj = ParseFiles(fileList)
            if ~iscell(fileList)
                fileList = {fileList};
            end
            obj.fileList = fileList;
            % check for pdf files
            for i = 1:numel(obj.fileList)
                % if pdf files are in the project ...
                [~,~,ext] = fileparts(obj.fileList{i});
                if strcmp(ext, '.pdf')
                    % find where the pdf converter is on this computer
                    obj.locatePDFConverter();
                    break; % stop searching filelist for pdfs
                end
            end
        end
        
%         function obj = runSequentially(obj)
%             % for each file
%             % get document type
%             % use relevant parse script to get list of words and title
%             % remove all words containing non alphabet characters or empties
%             % remove all common words
%             % more clever regular expression stuff?
%             % From word list find unique words and their count
%             % sort word list and counts alphabetically (use key/value store?)
%             % find unique keywords for whole project
%             % reorder each paper's word counts so they are the same order
%             % as the new unique keyword list
%             
%             % output should be something like a 2D matrix of word counts
%             % one dimension indexed by project keywords
%             % other dimension indexed by paper title
%         end
        
        function obj = locatePDFConverter(obj)
            % check for saved temp file containing pdftotext location
            obj.pdfConverter = obj.getPDFConverterFromTempDrive();
            % if there is no path saved to temp (or it was invalid)
            if isempty(obj.pdfConverter)
                % prompt the user for the converter's location
                obj.pdfConverter = obj.getPDFConverterLocationFromUser();
                % if we got the pdf converter from the user, save it
                if ~isempty(obj.pdfConverter)
                    obj.savePDFConverterToTempDrive(obj.pdfConverter);
                else
                    % If we still don't have a location after
                    % asking the user for one then we cancel the
                    % parse command with an error
                    errordlg(['MATLAB cannot parse pdf files without', ...
                        'the pdftotext function installed.', ...
                        'Either install Xpdf or remove PDFs from project']);
                end
            end
        end
        
        function location = getPDFConverterFromTempDrive(~)
            location = '';
            tempfilename = fullfile(tempdir, 'pdftotextlocation.txt');
            
            % if the temp file exists, read it in
            if exist(tempfilename, 'file')
                fid = fopen(tempfilename, 'r');
                cachedLocation = fgetl(fid);
                fclose(fid);
                % check the file location is still valid
                if exist(cachedLocation, 'file')
                    % return cached location if it is still valid
                    location = cachedLocation;
                end
            end
        end
        
        function savePDFConverterToTempDrive(~, location)
            tempfilename = fullfile(tempdir, 'pdftotextlocation.txt');
            fid = fopen(tempfilename, 'w');
            fprintf(fid, '%s', location);
            fclose(fid);
        end
        
        function location = getPDFConverterLocationFromUser(~)
            % locate pdf conversion utility
            dialogueString = {'There is a PDF file in your project.', ...
                'To parse PDFs you need to install the (free) Xpdf utility from:', ...
                'http://www.foolabs.com/xpdf/download.html.', ...
                '','Where is the pdftotext utility located on your system?'};
            answer = questdlg(dialogueString, 'Locate pdftotext', ...
                'Locate pdftotext', 'Open Website', 'Cancel', 'Cancel');
            
            switch answer
                case 'Locate pdftotext'
                    [f,p,~] = uigetfile('*.*', 'Locate pdftotext');
                    % if the wrong thing was selected and the user didn't cancel then
                    % reprompt for the file location.
                    while ~strncmp(f, 'pdftotext', 9) && ~isequal(f,0)
                        uiwait(warndlg('That was not the pdftotext executable file'));
                        [f,p,~] = uigetfile('*.*', 'Locate pdftotext', p);
                    end
                    % deal with the case where user cancelled
                    if isequal(f,0)
                        location = '';
                    else
                        % return pdftotext location
                        location = fullfile(p,f);
                    end
                case 'Open Website'
                    web('http://www.foolabs.com/xpdf/download.html', '-browser');
                    location = '';
                case 'Cancel'
                    location = '';
            end
        end
    end
    
end

