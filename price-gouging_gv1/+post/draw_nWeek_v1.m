function draw_nWeek_v1( income_nW_counts_ban_ratio, income_nW_counts_noban_ratio, nW_avg_ban, nW_avg_noban, isColorbar, incomeTicks, incomeTickLabels,  dataName1, nWeek_ticks, nWeek_tickLabels, fsz_subtitle, fsz_tick, fsz_label, fsz_cb )

if ~isColorbar
    figure('Position', [10 10 1000 400])
else
    figure('Position', [10 10 1000+40 400])
end
t = tiledlayout(1,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';

nexttile
imagesc( income_nW_counts_ban_ratio );
title( sprintf('(i) Ban  -  %1.2f weeks on average', nW_avg_ban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
ax = gca;

ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

ax.XTick = nWeek_ticks;
ax.XTickLabel = nWeek_tickLabels;

xlabel( 'Time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )


nexttile
imagesc( income_nW_counts_noban_ratio );
title( sprintf('(ii) No ban  -  %1.2f weeks on average', nW_avg_noban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.XTick = nWeek_ticks;
ax.XTickLabel = nWeek_tickLabels;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

if isColorbar
    cb = colorbar;
    cb.Layout.Tile = 'east';
    cb.Label.String = 'Percentage of population';
    cb.Label.FontSize = fsz_cb;
    clim([0, 0.75])
end

fname_out = load( strcat("outputs\", dataName1, ".mat"), "fname_out" ).fname_out; vName = load( strcat("outputs\", dataName1, ".mat"), "vName" ).vName;
exportgraphics(gcf, strcat('figs/', fname_out, vName, '_nWeek.png'), 'Resolution', 500)