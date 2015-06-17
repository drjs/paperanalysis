f = gcf;
% if background is light, use dark logo else use white text logo
if sum(f.Color) > 1.5
    % MathWorks Blue: http://www.mathworks.co.uk/brandguide/visual/color.html
    fontColour = [18, 86, 135] ./255;
else
    fontColour = [1 1 1];
end
logofile = 'L-Membrane_RGB_R.png';

[im,~,alpha] = imread(logofile);
newX = 0.10;
newY = newX * size(im, 1) / size(im, 2);
logoax = axes('Position', [1-newX 0.02 newX, newY], ...
    'Color', 'none', 'Clipping', 'off', 'Layer', 'top', ...
    'Parent', f, 'Visible', 'off', 'Units', 'normalized');

logoHandle = image(im, 'AlphaData', alpha);
logoText   = text(0.9, 1.4, 'Made with', 'Parent', logoax, ...
    'HorizontalAlignment', 'right', 'Units', 'normalized', ...
    'FontUnits', 'normalized', 'FontSize', 0.2, 'Color', fontColour);
logoTextML = text(0.9, 1.2, 'MATLAB', 'Parent', logoax, ...
    'HorizontalAlignment', 'right', 'Units', 'normalized', ...
    'FontUnits', 'normalized', 'FontSize', 0.2, 'Color', fontColour);

axis(logoax, 'image')
axis(logoax, 'off')