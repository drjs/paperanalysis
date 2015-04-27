function obj = locatePDFConverter(obj)
% check for saved temp file containing pdftotext location
obj.pdfConverter = getPDFConverterFromTempDrive();
% if there is no path saved to temp (or it was invalid)
if isempty(obj.pdfConverter)
    % prompt the user for the converter's location
    obj.pdfConverter = getPDFConverterLocationFromUser();
    % if we got the pdf converter from the user, save it
    if ~isempty(obj.pdfConverter)
        savePDFConverterToTempDrive(obj.pdfConverter);
    else
        % If we still don't have a location after
        % asking the user for one then we cancel the
        % parse command with an error
        errordlg(['MATLAB cannot parse pdf files without', ...
            'the pdftotext function installed.', ...
            'Either install Xpdf or remove PDFs from project']);
    end
end


    function location = getPDFConverterFromTempDrive()
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

    function savePDFConverterToTempDrive(location)
        tempfilename = fullfile(tempdir, 'pdftotextlocation.txt');
        fid = fopen(tempfilename, 'w');
        fprintf(fid, '%s', location);
        fclose(fid);
    end

    function location = getPDFConverterLocationFromUser()
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