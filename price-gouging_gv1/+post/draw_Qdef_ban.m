function draw_Qdef_ban( dataName1, nWeek_Qb_bounds, Qmag_bounds, nWeek_Qb_ticks, nWeek_Qb_tickLabels, Qmag_ticks, Qmag_tickLabels_percent, fsz_label, fsz_subtitle, fsz_tick, figName, isColorbar, fsz_cb )

if ~isColorbar
    figure('Position', [10 10 1000 135]);
else
    figure('Position', [10 10 1000 135+80]);
end
t = tiledlayout(1,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
nexttile;

[income_nW_counts_ban_ratio, income_Qmag_counts_ban_ratio, nW_avg_ban, Qmag_avg_ban] = post.countShortTerm_ban( dataName1, nWeek_Qb_bounds, Qmag_bounds );
imagesc( income_nW_counts_ban_ratio )
title( sprintf('(i) Duration  -  %2.1f weeks on average', nW_avg_ban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
xlabel( 'Weeks', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = 1;
ax.YTickLabel = 'All';

ax.XTick = nWeek_Qb_ticks;
ax.XTickLabel = nWeek_Qb_tickLabels;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';
clim([0,1])

if isColorbar
    cb = colorbar;
    cb.Location = 'southoutside';
    cb.Label.String = 'Percentage of population';
    cb.Label.FontSize = fsz_cb;
end


nexttile;
imagesc( income_Qmag_counts_ban_ratio )
title( sprintf('(ii) Magnitude  -  %4.0f%% on average', Qmag_avg_ban*100), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = [];

ax.XTick = Qmag_ticks;
ax.XTickLabel = Qmag_tickLabels_percent;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';
xlabel( '% to original consumption', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
clim([0,1])

exportgraphics(gcf, strcat('figs/', figName, '.png'), 'Resolution', 500)
