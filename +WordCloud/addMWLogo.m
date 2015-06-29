function logoax = addMWLogo(figHandle)
% Copyright 2015 The MathWorks Inc.

% if background is light, use dark logo else use white text logo
if sum(figHandle.Color) > 1.5
    logofile = fullfile('+WordCloud', 'MATLAB_RGB.png');
    % MathWorks Blue: http://www.mathworks.co.uk/brandguide/visual/color.html
    fontColour = [18, 86, 135] ./255;
else
    logofile = fullfile('+WordCloud', 'MATLAB_rev.png');
    fontColour = [1 1 1];
end

[im,~,alpha] = imread(logofile);
sizeX = 0.20; % sizeX controls how big the logo displays
sizeY = sizeX * size(im, 1) / size(im, 2);
logoax = axes('Position', [1-sizeX 0.01 sizeX sizeY], ...
    'Color', 'none', 'Clipping', 'off', 'Layer', 'top', ...
    'Parent', figHandle, 'Visible', 'off', 'Units', 'normalized');

%logoHandle = imagesc([newX 1-newX], [0.01 newY], im, 'AlphaData', alpha);
logoHandle = image(im, 'AlphaData', alpha, 'Parent', logoax);
logoText   = text(0.9, 1.35, 'Made with', 'Parent', logoax, ...
    'HorizontalAlignment', 'right', 'Units', 'normalized', ...
    'FontUnits', 'normalized', 'FontSize', 0.7, 'Color', fontColour);

axis(logoax, 'image')
axis(logoax, 'off')