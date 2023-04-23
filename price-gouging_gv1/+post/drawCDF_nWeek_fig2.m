function [exceedProb_ban, exceedProb_noban] = drawCDF_nWeek_fig2( nWeekRec_ban, nWeekRec_noban, incomeGroupInds, nWeek_max, lineTypes, lineColors, fsz_label, fsz_tick, lw, fsz_subtitle, figName1, isLegend, fsz_lg, isLastTickBold )

nIncomeGroup = max(incomeGroupInds);

exceedProb_ban = zeros(nWeek_max,nIncomeGroup);
for iIcInd = 1:nIncomeGroup
    iNWeeks = nWeekRec_ban(:, incomeGroupInds==iIcInd);

    for jNWeek = 1:nWeek_max
        jProb = mean( iNWeeks <= jNWeek, "all" );
        exceedProb_ban(jNWeek, iIcInd) = jProb;
    end

end

exceedProb_noban = zeros(nWeek_max,nIncomeGroup);
for iIcInd = 1:nIncomeGroup
    iNWeeks = nWeekRec_noban(:, incomeGroupInds==iIcInd);

    for jNWeek = 1:nWeek_max
        jProb = mean( iNWeeks <= jNWeek, "all" );
        exceedProb_noban(jNWeek, iIcInd) = jProb;
    end

end

figure('Position', [10 10 1000 400])
t = tiledlayout(1,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';

nexttile
hold on
for iIcInd = 1:nIncomeGroup
    plot( exceedProb_ban(:,iIcInd), "Color", lineColors(iIcInd)*[1 1 1], "LineStyle", lineTypes{iIcInd}, "LineWidth", lw );
end
if isLegend
    leg = legend( ["0%-20%" "20%-30%" "30%-40%" "40%-50%" "50%-60%" "60%-70%" "70%-80%" "80%-90%" "90%-100%"], FontName='Times New Roman', FontSize=fsz_lg, Location='southeast' );
    title( leg, 'Income group', FontName='Times New Roman', FontSize=fsz_lg )
end
grid on

title( '(i) Ban', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

axis([0 nWeek_max 0 1])
ax = gca;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

if isLastTickBold
    xTicklabels = ax.XTickLabel;
    xTicklabels{end} = strcat( '\bf{', xTicklabels{end}, '}');
    ax.XTickLabel = xTicklabels;
end

xlabel( 'Number of weeks', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Cumulative distribution function', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )


nexttile
hold on
for iIcInd = 1:nIncomeGroup
    plot( exceedProb_noban(:,iIcInd), "Color", lineColors(iIcInd)*[1 1 1], "LineStyle", lineTypes{iIcInd}, "LineWidth", lw );
end
grid on

title( '(ii) No ban', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

axis([0 nWeek_max 0 1])
ax = gca;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

if isLastTickBold
    xTicklabels = ax.XTickLabel;
    xTicklabels{end} = strcat( '\bf{', xTicklabels{end}, '}');
    ax.XTickLabel = xTicklabels;
end

xlabel( 'Number of weeks', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

exportgraphics(gcf, strcat('figs/nw_cdf_', figName1, '.png'), 'Resolution', 500)