f = gcf;
% if background is light, use dark logo else use white text logo
if sum(f.Color) > 1.5
    logofile = 'MATLAB_RGB.png';
    % MathWorks Blue: http://www.mathworks.co.uk/brandguide/visual/color.html
    fontColour = [18, 86, 135] ./255;
else
    logofile = 'MATLAB_rev.png';
    fontColour = [1 1 1];
end

[im,~,alpha] = imread(logofile);
newX = 0.20;
newY = newX * size(im, 1) / size(im, 2);
logoax = axes('Position', [1-newX 0.01 newX, newY], ...
    'Color', 'none', 'Clipping', 'off', 'Layer', 'top', ...
    'Parent', f, 'Visible', 'off', 'Units', 'normalized');

logoHandle = image(im, 'AlphaData', alpha);
logoText   = text(0.9, 1.35, 'Made with', 'Parent', logoax, ...
    'HorizontalAlignment', 'right', 'Units', 'normalized', ...
    'FontUnits', 'normalized', 'FontSize', 0.7, 'Color', fontColour);

axis(logoax, 'image')
axis(logoax, 'off')