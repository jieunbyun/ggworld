% close all;
clear;
nBin = 10;
fsz_subtitle = 12; fsz_tick = 11; fsz_label = 12; fsz_cb = 12;

load outputs/default_v4.mat
% load outputs\mid_dPd_v4.mat
% load outputs/high_dPd_v4.mat
% load outputs/low_loss_v4.mat % not much difference between the two cases
% load outputs/high_goug_v4.mat % message the same as "high_dPd"
% load outputs/eq_income_v4.mat % not much characteristic
% load outputs/hoarding_v4.mat
% load outputs/donation_v4.mat
% load outputs/bond_v4.mat
nPop = length(myWeeklyIncome);
nSample = size( result.loss_pop, 1 );

%% Full recovery -- average
nWeekRec_avg_ban = mean(result.nWeekRec_ban,1);
nWeekRec_avg_noban = mean(result.nWeekRec_noban,1);

income_quantiles = quantile(myWeeklyIncome, [0, 0.2:0.1:1.0]); 
nWeekRec_avg_max = max( [nWeekRec_avg_ban(:); nWeekRec_avg_noban(:)] );
nWeekRec_bounds = linspace(0, nWeekRec_avg_max, nBin+1); 
income_nW_counts_ban = post.my_hist3( myWeeklyIncome, nWeekRec_avg_ban, income_quantiles, nWeekRec_bounds );
income_nW_counts_noban = post.my_hist3( myWeeklyIncome, nWeekRec_avg_noban, income_quantiles, nWeekRec_bounds );

income_nW_counts_ban_ratio = income_nW_counts_ban ./ sum(income_nW_counts_ban,2);
income_nW_counts_noban_ratio = income_nW_counts_noban ./ sum(income_nW_counts_noban,2);

nW_avg_ban = mean( nWeekRec_avg_ban );
nW_avg_noban = mean( nWeekRec_avg_noban );

figure('Renderer', 'painters', 'Position', [10 10 1000 400])
tiledlayout(1,2);
nexttile
imagesc( income_nW_counts_ban_ratio )
title( sprintf('(i) Ban  -  %1.2f weeks on average', nW_avg_ban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
ax = gca;

incomeTicks = 1:2:size(income_nW_counts_ban,1);
incomeTickLabels = arrayfun( @(x) strcat( num2str(x), ' %' ), 20:20:100, 'UniformOutput', false );

ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

nWeekRec_avg_ticks = 1:size(income_nW_counts_ban,2);
nWeekRec_avg_tickLabels = strsplit(num2str ( round( nWeekRec_bounds(nWeekRec_avg_ticks) ) ) );

ax.XTick = nWeekRec_avg_ticks;
ax.XTickLabel = nWeekRec_avg_tickLabels;

xlabel( 'Average time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

nexttile
imagesc( income_nW_counts_noban_ratio )
title( sprintf('(ii) No ban  -  %1.2f weeks on average', nW_avg_noban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.XTick = nWeekRec_avg_ticks;
ax.XTickLabel = nWeekRec_avg_tickLabels;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Average time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = 'Percentage of population';
cb.Label.FontSize = fsz_cb;


exportgraphics(gcf, strcat('figs/', fname_out, vName, '_nWeek_avg.png'), 'Resolution', 500)


%% Full recovery -- aggregate
nWeekRec_ban = result.nWeekRec_ban;
nWeekRec_noban = result.nWeekRec_noban;

nWeekRec_max = max( [nWeekRec_ban(:); nWeekRec_noban(:)] );
nWeekRec_bounds_agg = linspace(0, nWeekRec_max, nBin+1); 
income_nW_counts_ban_agg = zeros(length(income_quantiles)-1, nBin);
income_nW_counts_noban_agg = zeros(length(income_quantiles)-1, nBin);
for iSampInd = 1:nSample
    income_nW_counts_ban_agg = income_nW_counts_ban_agg + post.my_hist3( myWeeklyIncome, nWeekRec_ban(iSampInd,:), income_quantiles, nWeekRec_bounds_agg );
    income_nW_counts_noban_agg = income_nW_counts_noban_agg + post.my_hist3( myWeeklyIncome, nWeekRec_noban(iSampInd,:), income_quantiles, nWeekRec_bounds_agg );
end

income_nW_counts_ban_agg_ratio = income_nW_counts_ban_agg ./ sum(income_nW_counts_ban_agg,2);
income_nW_counts_noban_agg_ratio = income_nW_counts_noban_agg ./ sum(income_nW_counts_noban_agg,2);

figure('Renderer', 'painters', 'Position', [10 10 1000 400])
tiledlayout(1,2);
nexttile
imagesc( income_nW_counts_ban_agg_ratio )
title( '(i) Ban', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
ax = gca;

incomeTicks = 1:2:size(income_nW_counts_ban,1);
incomeTickLabels = arrayfun( @(x) strcat( num2str(x), ' %' ), 20:20:100, 'UniformOutput', false );

ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

nWeekRec_avg_ticks = 1:size(income_nW_counts_ban,2);
nWeekRec_avg_tickLabels = strsplit(num2str ( round( nWeekRec_bounds(nWeekRec_avg_ticks) ) ) );

ax.XTick = nWeekRec_avg_ticks;
ax.XTickLabel = nWeekRec_avg_tickLabels;

xlabel( 'Time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

nexttile
imagesc( income_nW_counts_noban_agg_ratio )
title( '(ii) No ban', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.XTick = nWeekRec_avg_ticks;
ax.XTickLabel = nWeekRec_avg_tickLabels;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = 'Percentage of population';
cb.Label.FontSize = fsz_cb;


exportgraphics(gcf, strcat('figs/', fname_out, vName, '_nWeek_agg.png'), 'Resolution', 500)

%% Lack of basic supply
Qb_def_nWeek_noban = mean(result.Qb_def_nWeek_noban,1);
Qb_def_nWeek_ban = result.Q_supply_lack_nWeek_Qb;
Qb_def_nWeek_max = max([Qb_def_nWeek_noban(:); Qb_def_nWeek_ban(:)]);
Qb_def_nWeek_bounds = [0, 0.1+(1:Qb_def_nWeek_max)]; 
Qb_def_nWeek_noban_counts = post.my_hist3( myWeeklyIncome, Qb_def_nWeek_noban, income_quantiles, Qb_def_nWeek_bounds);
Qb_def_nWeek_noban_counts_ratio = Qb_def_nWeek_noban_counts ./ sum(Qb_def_nWeek_noban_counts,2);

Qb_def_nWeek_ban_counts = post.my_hist( Qb_def_nWeek_ban, Qb_def_nWeek_bounds );
Qb_def_nWeek_ban_counts_ratio = Qb_def_nWeek_ban_counts / sum(Qb_def_nWeek_ban_counts);

figure('Renderer', 'painters', 'Position', [10 10 1000 500])
T = tiledlayout(10,2);
nexttile(1, [2, 1]);
imagesc( Qb_def_nWeek_ban_counts_ratio )
title( '(i-1) Ban (the same for all persons)', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = [];
Qb_def_nWeek_ticks = 1:size(Qb_def_nWeek_noban_counts,2);
ax.XTick = Qb_def_nWeek_ticks;
ax.XTickLabel = strsplit(num2str ( Qb_def_nWeek_ticks ) );
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';


nexttile( 5, [8, 1] );
imagesc( Qb_def_nWeek_noban_counts_ratio )

title( '(i-2) No ban', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
xlabel( 'Time for supply to meet demand (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )
ylabel( 'Income percentile', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

Qb_def_nWeek_ticks = 1:size(Qb_def_nWeek_noban_counts,2);
ax.XTick = Qb_def_nWeek_ticks;
ax.XTickLabel = strsplit(num2str ( Qb_def_nWeek_ticks ) );

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';


Qb_def_mag_noban = mean(result.Qb_def_mag_noban, 1);
Qb_def_mag_ban = result.Q_supply_lack_mag_Qb;
Qb_def_mag_max = max([Qb_def_mag_noban(:); Qb_def_mag_ban(:)]);
Qb_def_mag_bounds = linspace(0, Qb_def_mag_max, nBin+1); 
Qb_def_mag_noban_counts = post.my_hist3( myWeeklyIncome, Qb_def_mag_noban, income_quantiles, Qb_def_mag_bounds);
Qb_def_mag_noban_counts_ratio = Qb_def_mag_noban_counts ./ sum(Qb_def_mag_noban_counts,2);
% --> The most vulnerable income groups (e.g. low-, mid- and high-income) is most affected by "q_b_fun"; for example, the higher "q_min", the more vulnerable the low-income group are, and the higher "alp_min", the more vulnerable higher-income groups are.

Qb_def_mag_ban = post.my_hist( Qb_def_mag_ban, Qb_def_mag_bounds );
Qb_def_mag_ban_ratio = Qb_def_mag_ban / sum(Qb_def_mag_ban);

nexttile(2, [2, 1]);
imagesc( Qb_def_mag_ban_ratio )
title( '(ii-1) Ban (the same for all persons)', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = [];
Qb_def_mag_ticks = 1:size(Qb_def_mag_noban_counts,2);
ax.XTick = Qb_def_mag_ticks;
ax.XTickLabel = strsplit(num2str ( round(Qb_def_mag_bounds, 2) ) );
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

nexttile(6, [8, 1]);
imagesc( Qb_def_mag_noban_counts_ratio )

title( '(ii-2) No ban', 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
xlabel( 'Cumulative deficit of demand (ratio)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

ax.XTick = Qb_def_mag_ticks;
ax.XTickLabel = strsplit(num2str ( round(Qb_def_mag_bounds, 2) ) );

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = 'Percentage of population';
cb.Label.FontSize = fsz_cb;

exportgraphics(gcf, strcat('figs/', fname_out, vName, '_suppLack.png'), 'Resolution', 500)
