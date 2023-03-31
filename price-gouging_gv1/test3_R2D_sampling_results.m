close all; clear;
nBin = 10;
fsz_subtitle = 12; fsz_tick = 11; fsz_label = 12;

load outputs/default.mat

%% Full recovery
nWeekRec_avg_ban = mean(result.nWeekRec_ban,1);
nWeekRec_avg_noban = mean(result.nWeekRec_noban,1);

income_quantiles = quantile(myWeeklyIncome, [0, 0.2:0.1:1.0]); 
nWeekRec_avg_max = max( [nWeekRec_avg_ban(:); nWeekRec_avg_noban(:)] );
nWeekRec_bounds = linspace(0, nWeekRec_avg_max, nBin); 
income_nW_counts_ban = post.my_hist3( myWeeklyIncome, nWeekRec_avg_ban, income_quantiles, nWeekRec_bounds );
income_nW_counts_noban = post.my_hist3( myWeeklyIncome, nWeekRec_avg_noban, income_quantiles, nWeekRec_bounds );

nW_avg_ban = mean( nWeekRec_avg_ban );
nW_avg_noban = mean( nWeekRec_avg_noban );

figure('Renderer', 'painters', 'Position', [10 10 1000 400])
subplot(1,2,1);
image( income_nW_counts_ban )
title( sprintf('Ban  -  %1.2f weeks on average', nW_avg_ban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
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

subplot(1,2,2); 
image( income_nW_counts_noban )
title( sprintf('No ban  -  %1.2f weeks on average', nW_avg_noban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )

ax = gca;
ax.XTick = nWeekRec_avg_ticks;
ax.XTickLabel = nWeekRec_avg_tickLabels;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;
ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

xlabel( 'Average time to full recovery (weeks)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )


%% Lack of basic supply
Qb_def_nWeek_noban = result.Qb_def_nWeek_noban(1,:);
Qb_def_nWeek_noban_max = max(Qb_def_nWeek_noban);
Qb_def_nWeek_noban_bounds = 0:Qb_def_nWeek_noban_max; 
Qb_def_nWeek_noban_counts = post.my_hist3( myWeeklyIncome, Qb_def_nWeek_noban, income_quantiles, Qb_def_nWeek_noban_bounds);

Qb_def_mag_noban = result.Qb_def_mag_noban(1,:);
Qb_def_mag_noban_max = max(Qb_def_mag_noban);
Qb_def_mag_noban_bounds = linspace(0, Qb_def_mag_noban_max, nBin); 
Qb_def_mag_noban_counts = post.my_hist3( myWeeklyIncome, Qb_def_mag_noban, income_quantiles, Qb_def_mag_noban_bounds);
% --> The most vulnerable income groups (e.g. low-, mid- and high-income) is most affected by "q_b_fun"; for example, the higher "q_min", the more vulnerable the low-income group are, and the higher "alp_min", the more vulnerable higher-income groups are.

Qb_def_nWeek_ban = result.Q_supply_lack_nWeek_Qb(1);
Qb_def_mag_ban = result.Q_supply_lack_mag_Qb(1);

figure('Renderer', 'painters', 'Position', [10 10 1000 400])
subplot(1,2,1); 
image( Qb_def_nWeek_noban_counts )

title( sprintf('No ban (with ban, it is %d weeks long)', Qb_def_nWeek_ban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
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

subplot(1,2,2);
image( Qb_def_mag_noban_counts )

title( sprintf('No ban (with ban, it sums up to %1.2f.)', Qb_def_mag_ban), 'FontSize', fsz_subtitle, 'FontName', 'Times New Roman' )
xlabel( 'Cumulative deficit of demand (ratio)', 'FontSize', fsz_label, 'FontName', 'Times New Roman' )

ax = gca;
ax.YTick = incomeTicks;
ax.YTickLabel = incomeTickLabels;

Qb_def_mag_ticks = 1:size(Qb_def_mag_noban_counts,2);
ax.XTick = Qb_def_mag_ticks;
ax.XTickLabel = strsplit(num2str ( round(Qb_def_mag_noban_bounds, 2) ) );

ax.FontSize = fsz_tick;
ax.FontName = 'Times New Roman';

