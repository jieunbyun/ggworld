function [income_nW_counts_ban_ratio, income_Qmag_counts_ban_ratio, nW_avg_ban, Qmag_avg_ban] = countShortTerm_ban( dataName1, nWeek_Qb_bounds, Qmag_bounds )

data = load( strcat( "outputs\", dataName1, ".mat" ), "result" );

nWeek_ban = data.result.Q_supply_lack_nWeek_Qb;
Qb_def_mag_ban = data.result.Q_supply_lack_mag_Qb;

income_nW_counts_ban = post.my_hist( nWeek_ban, nWeek_Qb_bounds );
income_Qmag_counts_ban = post.my_hist( Qb_def_mag_ban, Qmag_bounds );

income_nW_counts_ban_ratio = income_nW_counts_ban ./ sum(income_nW_counts_ban,2);
income_Qmag_counts_ban_ratio = income_Qmag_counts_ban ./ sum(income_Qmag_counts_ban, 2);

nW_avg_ban = mean( nWeek_ban(:) );
Qmag_avg_ban = mean(Qb_def_mag_ban(:));