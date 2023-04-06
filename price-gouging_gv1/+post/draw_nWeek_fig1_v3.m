function draw_nWeek_fig1_v3( income_nW_counts_ratio, nW_avg, isColorbar, incomeTicks, incomeTickLabels, nWeek_ticks, nWeek_tickLabels, fsz_subtitle, fsz_tick, fsz_label, fsz_cb,  figName )

if ~isColorbar
    figure('Position', [10 10 560 420])
else
    figure('Position', [10 10 560+40 420])
end


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
    cb.Location = 'eastoutside';
    cb.Label.String = 'Percentage of population';
    cb.Label.FontSize = fsz_cb;
    
end
clim([0, 0.75])

exportgraphics(gcf, strcat('figs/', figName, '.png'), 'Resolution', 500)