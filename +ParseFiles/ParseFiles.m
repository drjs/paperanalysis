classdef ParseFiles < handle
    %PARSEFILES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fileList;
        pdfConverter;
    end
    
    methods
        function obj = ParseFiles(fileList)
            obj.fileList = fileList;
            % check for pdf files
            for f = obj.fileList
                % if pdf files are in the project ...
                [~,~,ext] = fileparts(f);
                if strcmp(ext, '.pdf')
                    obj.pdfConverter = obj.getPDFConverterLocationFromUser();
                    break;
                end
            end
        end
        
        function obj = runSequentially(obj)
            % for each file
            % get document type
            % use relevant parse script to get list of words and title
            % remove all words containing non alphabet characters or empties
            % remove all common words
            % more clever regular expression stuff?
            % From word list find unique words and their count
            % sort word list and counts alphabetically (use key/value store?)
            % find unique keywords for whole project
            % reorder each paper's word counts so they are the same order
            % as the new unique keyword list
            
            % output should be something like a 2D matrix of word counts
            % one dimension indexed by project keywords
            % other dimension indexed by paper title
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
                        location = 0;
                    else
                        % return pdftotext location
                        location = fullfile(p,f);
                    end
                    break;
                case 'Open Website'
                    web('http://www.foolabs.com/xpdf/download.html', '-browser');
                    break;
                case 'Cancel'
                    location = 0;
                    break;
            end
        end
    end
    
end

