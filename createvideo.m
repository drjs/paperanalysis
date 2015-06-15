h=gcf;
h=h.Children(2);


OptionZ.Periodic = 1;
OptionZ.FrameRate = 24;
OptionZ.Duration = 25;

angle = [0 90;30 8; 110 8; 190 8; 270 8; 360 90]

CaptureFigVid(angle, 'SEFI2015_vid2',OptionZ)
