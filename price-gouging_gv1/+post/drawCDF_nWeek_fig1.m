function exceedProb = drawCDF_nWeek_fig1( nWeekRec, incomeGroupInds, nWeek_max, lineTypes, lineColors, fsz_label, fsz_tick, lw, figName1, isLegend, fsz_lg )

nIncomeGroup = max(incomeGroupInds);

exceedProb = zeros(nWeek_max,nIncomeGroup);
for iIcInd = 1:nIncomeGroup
    iNWeeks = nWeekRec(:, incomeGroupInds==iIcInd);

    for jNWeek = 1:nWeek_max
        jProb = mean( iNWeeks <= jNWeek, "all" );
        exceedProb(jNWeek, iIcInd) = jProb;
    end

end

figure;
hold on
for iIcInd = 1:nIncomeGroup
    plot( exceedProb(:,iIcInd), "Color", lineColors(iIcInd)*[1 1 1], "LineStyle", lineTypes{iIcInd}, "LineWidth", lw );
end
if isLegend
    leg = legend( ["0%-20%" "20%-30%" "30%-40%" "40%-50%" "50%-60%" "60%-70%" "70%-80%" "80%-90%" "90%-100%"], FontName='Times New Roman', FontSize=fsz_lg, Location='southeast' );
    title( leg, 'Income group', FontName='Times New Roman', FontSize=fsz_lg )
end
grid on

axis([0 nWeek_max 0 1])
ax = gca;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Number of weeks', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Cumulative distribution function', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

exportgraphics(gcf, strcat('figs/nw_cdf_', figName1, '.png'), 'Resolution', 500)