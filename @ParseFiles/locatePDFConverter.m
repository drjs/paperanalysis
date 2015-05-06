function obj = locatePDFConverter(obj)
prefgroup = 'WordCloud';
prefname  = 'pdfConverter';

% check for pdftotext location preference
try
    obj.pdfConverter = getpref(prefgroup, prefname);
    if ~isLocationValid(obj.pdfConverter)
        rmpref(prefgroup, prefname);
        error('Saved PDF converter preference is no longer valid')
    end
    % if there is no preference saved getpref will error...
catch
    % prompt the user for the converter's location
    obj.pdfConverter = getPDFConverterLocationFromUser();
    % if we got the pdf converter from the user, save it
    if ~isempty(obj.pdfConverter) && isLocationValid(obj.pdfConverter)
        setpref(prefgroup, prefname, obj.pdfConverter);
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

function isvalid = isLocationValid(location)
% to be valid, the file must exist and be called pdftotext
[~,name,~] = fileparts(location);
isvalid = exist(location, 'file') && strcmp(name, 'pdftotext');

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
        [f,p,~] = uigetfile('*.*', 'Locate pdftotext')
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
