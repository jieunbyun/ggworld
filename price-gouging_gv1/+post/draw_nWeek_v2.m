function draw_nWeek_v2( income_nW_counts_ratio, nW_avg, incomeTicks, incomeTickLabels, nWeek_ticks, nWeek_tickLabels, fsz_subtitle, fsz_tick, fsz_label, fsz_cb, isColorbar, figName )

figure('Position', [100 100 560+50 420])
imagesc( income_nW_counts_ratio );
title( sprintf('%1.2f weeks on average', nW_avg), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
ax = gca;

ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

ax.XTick = nWeek_ticks;
ax.XTickLabel = nWeek_tickLabels;

xlabel( 'Time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

if isColorbar
    cb = colorbar;
    cb.Label.String = 'Percentage of population';
    cb.Label.FontSize = fsz_cb;
    clim([0, 0.75])
end

exportgraphics(gcf, strcat('figs/', figName, '.png'), 'Resolution', 500)