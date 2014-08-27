function  makeCorrelationPlot(MATRIX,TYPE,LABELS)
    Corr_Spr = corr(MATRIX,'type',TYPE);
    surf( (Corr_Spr));
    axis square;  view([0 90])
    xlim([1 size(Corr_Spr,1)]); ylim([1 size(Corr_Spr,1)]);
    shading flat;
    set(gca,'Xtick',1:size(Corr_Spr,1),'XTickLabel',LABELS,'XTickLabelRotation',45);
    set(gca,'Ytick',1:size(Corr_Spr,1),'YTickLabel',LABELS,'YTickLabelRotation',0);
end
