function [income_nW_counts_noban_ratio, income_Qmag_counts_noban_ratio, nW_avg_noban, Qmag_avg_noban] = countShortTerm_noban( dataName1, income_quantiles, nWeek_Qb_bounds, Qmag_bounds )

data = load( strcat( "outputs\", dataName1, ".mat" ), "result", "myWeeklyIncome" );

nWeek_noban = data.result.Qb_def_nWeek_noban;
Qb_def_mag_noban = data.result.Qb_def_mag_noban;
myWeeklyIncome = data.myWeeklyIncome;

nBin_i = length(income_quantiles) - 1;
nBin_n = length(nWeek_Qb_bounds) - 1;
nBin_q = length(Qmag_bounds) - 1;

income_nW_counts_noban = zeros( nBin_i, nBin_n );
income_Qmag_counts_noban = zeros( nBin_i, nBin_q );

nSample = size(nWeek_noban, 1);
for iSampInd = 1:nSample
    income_nW_counts_noban = income_nW_counts_noban + post.my_hist3( myWeeklyIncome, nWeek_noban(iSampInd,:), income_quantiles, nWeek_Qb_bounds );
    income_Qmag_counts_noban = income_Qmag_counts_noban + post.my_hist3( myWeeklyIncome, Qb_def_mag_noban(iSampInd,:), income_quantiles, Qmag_bounds );
end

income_nW_counts_noban_ratio = income_nW_counts_noban ./ sum(income_nW_counts_noban,2);
income_Qmag_counts_noban_ratio = income_Qmag_counts_noban ./ sum(income_Qmag_counts_noban, 2);

nW_avg_noban = mean( nWeek_noban(:) );
Qmag_avg_noban = mean(Qb_def_mag_noban(:));