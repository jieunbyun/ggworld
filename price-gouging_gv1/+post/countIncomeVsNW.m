function [income_nW_counts_ban_ratio, income_nW_counts_noban_ratio, nW_avg_ban, nW_avg_noban] = countIncomeVsNW( dataName1, income_quantiles, nWeek_bounds )

data = load( strcat( "outputs\", dataName1, ".mat" ), "result", "myWeeklyIncome" );

nWeek_ban = data.result.nWeekRec_ban;
nWeek_noban = data.result.nWeekRec_noban;
myWeeklyIncome = data.myWeeklyIncome;

nBin_i = length(income_quantiles) - 1;
nBin_n = length(nWeek_bounds) - 1;
income_nW_counts_ban = zeros( nBin_i, nBin_n );
income_nW_counts_noban = zeros( nBin_i, nBin_n );

nSample = size(nWeek_ban, 1);
for iSampInd = 1:nSample
    income_nW_counts_ban = income_nW_counts_ban + post.my_hist3( myWeeklyIncome, nWeek_ban(iSampInd,:), income_quantiles, nWeek_bounds );
    income_nW_counts_noban = income_nW_counts_noban + post.my_hist3( myWeeklyIncome, nWeek_noban(iSampInd,:), income_quantiles, nWeek_bounds );
end

income_nW_counts_ban_ratio = income_nW_counts_ban ./ sum(income_nW_counts_ban, 2);
income_nW_counts_noban_ratio = income_nW_counts_noban ./ sum(income_nW_counts_noban,2);


nW_avg_ban = mean( nWeek_ban(:) );
nW_avg_noban = mean( nWeek_noban(:) );