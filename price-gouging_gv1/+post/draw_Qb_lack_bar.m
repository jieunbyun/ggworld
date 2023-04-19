function draw_Qb_lack_bar(incomeGroupInds, incomeTicks, incomeTickLabels, lw, fsz_tick, fsz_label, fsz_lg, lineColor )

nIncomeGroup = max(incomeGroupInds);

load outputs/default_v4.mat
incomeGroup_Qb_lack_nw_noban = zeros( 1, nIncomeGroup );

for iIcInd = 1:nIncomeGroup
    iNW_mean = mean( result.Qb_def_nWeek_noban(:,incomeGroupInds==iIcInd), "all" );
    incomeGroup_Qb_lack_nw_noban(iIcInd) = iNW_mean;
end
figure('Position', [10 10 560 420])
bar( 1:nIncomeGroup, incomeGroup_Qb_lack_nw_noban, 'FaceColor', [0.8500, 0.3250, 0.0980] )
ax = gca;
xlim = ax.XLim;
ytick = ax.YTick;
yticklabel = arrayfun( @num2str, ytick, 'UniformOutput', false );
hold on
plot( xlim, mean(result.Q_supply_lack_nWeek_Qb)*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
ytick = [ytick mean(result.Q_supply_lack_nWeek_Qb)-0.2];
yticklabel = [yticklabel '170% PG'];
load outputs/mid_dPd_v4.mat
plot( xlim, mean(result.Q_supply_lack_nWeek_Qb)*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
ytick = [ytick mean(result.Q_supply_lack_nWeek_Qb)];
yticklabel = [yticklabel '135% PG'];
load outputs/high_dPd_v4.mat
plot( xlim, mean(result.Q_supply_lack_nWeek_Qb)*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
ytick = [ytick mean(result.Q_supply_lack_nWeek_Qb)+0.2];
yticklabel = [yticklabel '100% PG'];
grid on

ax.XTick = incomeTicks;
ax.XTickLabel = incomeTickLabels;

ax.YTick = ytick;
ax.YTickLabel = yticklabel;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

legend( {'Without ban' 'With ban'}, FontName='Times New Roman', FontSize=fsz_lg, Position = [0.655297619047619 0.722916666666667 0.233928571428571 0.0964285714285714] )

xlabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
% mylabel = ylabel( {'Average weeks of insufficiency in' 'basic goods'}, 'FontSize', fsz_label, 'FontName', 'Times New Roman' );
mylabel = ylabel( 'Average weeks', 'FontSize', fsz_label, 'FontName', 'Times New Roman' );
mylabel.Position(1) = -1;

exportgraphics(gcf, strcat('figs/nw_Qb_bar.png'), 'Resolution', 500)



load outputs/default_v4.mat
incomeGroup_Qb_lack_mag_noban = zeros( 1, nIncomeGroup );

for iIcInd = 1:nIncomeGroup
    iNW_mean = mean( result.Qb_def_mag_noban(:,incomeGroupInds==iIcInd), "all" );
    incomeGroup_Qb_lack_mag_noban(iIcInd) = iNW_mean;
end
figure('Position', [10 10 560 420])
bar( 1:nIncomeGroup, incomeGroup_Qb_lack_mag_noban, 'FaceColor', [0.8500, 0.3250, 0.0980] )
ax = gca;
xlim = ax.XLim;
ytick = 2:2:18;
yticklabel = arrayfun( @num2str, ytick, 'UniformOutput', false );
hold on
plot( xlim, mean(result.Q_supply_lack_mag_Qb)*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
ytick = [ytick mean(result.Q_supply_lack_mag_Qb)];
yticklabel = [yticklabel '170% PG'];
load outputs/mid_dPd_v4.mat
plot( xlim, mean(result.Q_supply_lack_mag_Qb)*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
ytick = [ytick mean(result.Q_supply_lack_mag_Qb)];
yticklabel = [yticklabel '135% PG'];
load outputs/high_dPd_v4.mat
plot( xlim, mean(result.Q_supply_lack_mag_Qb)*[1 1], Color = lineColor*[1 1 1], LineWidth=lw )
ytick = [ytick mean(result.Q_supply_lack_mag_Qb)];
yticklabel = [yticklabel '100% PG'];
grid on

[ytick, ytick_ind] = sort(ytick, 'ascend');
yticklabel = yticklabel(ytick_ind);
yticklabel(8) = {''};

ax.XTick = incomeTicks;
ax.XTickLabel = incomeTickLabels;

ax.YTick = ytick;
ax.YTickLabel = yticklabel;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
% mylabel = ylabel( {'Average magnitude of insufficiency in' 'basic goods'}, 'FontSize', fsz_label, 'FontName', 'Times New Roman' );
ylabel( 'Average magnitude', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

exportgraphics(gcf, strcat('figs/mag_Qb_bar.png'), 'Resolution', 500)