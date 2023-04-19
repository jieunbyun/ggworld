function draw_nWeek_Ql_bar(dataName1, figName1, incomeGroupInds, incomeTicks_all, incomeTickLabels_all, lineColor, lw, YTickOmitInd, fsz_tick, fsz_label, isLegend, fsz_lg)

nIncomeGroup = max(incomeGroupInds);

figure('Position', [10 10 560 420])
load(strcat("outputs/", dataName1, ".mat"))
incomeGroup_Ql_lack_nw_noban = zeros( 1, nIncomeGroup );
incomeGroup_Ql_lack_nw_ban = zeros( 1, nIncomeGroup );
for iIcInd = 1:nIncomeGroup
    iNw_mean_noban = mean( result.nWeekRec_noban(:,incomeGroupInds==iIcInd), "all" );
    incomeGroup_Ql_lack_nw_noban(iIcInd) = iNw_mean_noban;

    iNw_mean_ban = mean( result.nWeekRec_ban(:,incomeGroupInds==iIcInd), "all" );
    incomeGroup_Ql_lack_nw_ban(iIcInd) = iNw_mean_ban;
end

bar( 1:nIncomeGroup, [incomeGroup_Ql_lack_nw_ban; incomeGroup_Ql_lack_nw_noban] )
hold on
xlim = get(gca, 'xlim');
plot( xlim, mean( result.nWeekRec_noban, "all")*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
plot( xlim, mean( result.nWeekRec_ban, "all")*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
grid on
ax = gca;
ax.XTick = incomeTicks_all;
ax.XTickLabel = incomeTickLabels_all;

ytick = ax.YTick;
ytick = [ytick mean( result.nWeekRec_noban, "all") mean( result.nWeekRec_ban, "all")];
ytickLabel = ax.YTickLabel;
ytickLabel = [ytickLabel; "w/ ban"; "w/o ban"];

[ytick, ytick_ind] = sort(ytick, 'ascend');
ytickLabel = ytickLabel(ytick_ind);
ytickLabel(YTickOmitInd) = {' '};

ax.YTick = ytick;
ax.YTickLabel = ytickLabel;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( {'Average weeks of full repair'}, 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

if isLegend
    legend( {'With ban' 'Without ban' 'Average'}, FontName='Times New Roman', FontSize=fsz_lg, Location='northwest' )
end

exportgraphics(gcf, strcat('figs/nw_Ql_bar_', figName1, '.png'), 'Resolution', 500)