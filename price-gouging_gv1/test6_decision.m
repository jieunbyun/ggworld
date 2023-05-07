%% Total averages
% Total lack of basic goods (absolute price) -- this is what needs to be delivered by relief resources
dem_lack_abs_sum.noban = cellfun( @sum, dem_lack_abs_hist_noban );
dm.basic_shortage_all_noban = mean( dem_lack_abs_sum.noban );

dem_lack_abs_sum.ban = cellfun( @sum, dem_lack_abs_hist_ban );
dm.basic_shortage_all_ban = mean( dem_lack_abs_sum.ban );

% Mean number or weeks for repair
dm.repair_nWeek_all_noban = mean(repair_pop_nWeek_noban, "all");
dm.repair_nWeek_all_ban = mean( repair_pop_nWeek_ban, "all" );

% Well-being loss
wbl_income_sum_noban = cellfun( @(x) mean(sum(x)), wbl_pop_income_hist_noban );
dm.wbl_all_noban = mean( wbl_income_sum_noban );

wbl_income_sum_ban = cellfun( @(x) mean(sum(x)), wbl_pop_income_hist_ban );
dm.wbl_income_all_ban = mean( wbl_income_sum_ban );

wbl_supply_sum_ban = cellfun( @(x) mean(sum(x)), wbl_pop_supply_hist_ban );
dm.wbl_supply_all_ban = mean( wbl_supply_sum_ban );

dm.wbl_all_ban = dm.wbl_income_all_ban + dm.wbl_supply_all_ban;

%% Worst scenarios
worst_ratio_samp = 0.05; worst_ratio_pop = 0.2;

% Total lack of basic goods (absolute price)
dem_lack_abs_quant_noban = quantile( dem_lack_abs_sum.noban, 1-worst_ratio_samp );
dm.basic_shortage_worst_samp_noban = mean( dem_lack_abs_sum.noban( dem_lack_abs_sum.noban >= dem_lack_abs_quant_noban ) );

dem_lack_abs_quant_ban = quantile( dem_lack_abs_sum.ban, 1-worst_ratio_samp );
dm.basic_shortage_worst_samp_ban = mean( dem_lack_abs_sum.ban( dem_lack_abs_sum.ban >= dem_lack_abs_quant_ban ) );

dem_lack_abs_quant_noban = quantile( dem_lack_abs_sum.noban, 1-worst_ratio_samp );
dm.basic_shortage_worst_samp_noban = mean( dem_lack_abs_sum.noban( dem_lack_abs_sum.noban >= dem_lack_abs_quant_noban ) );

% Mean number or weeks for repair
repair_pop_nWeek_noban_mean = mean(repair_pop_nWeek_noban);
repair_pop_nWeek_quant_noban = quantile(repair_pop_nWeek_noban_mean, 1- worst_ratio_samp);
dm.repair_nWeek_all_worst_samp_noban = mean( repair_pop_nWeek_noban_mean( repair_pop_nWeek_noban_mean > repair_pop_nWeek_quant_noban ) );

repair_pop_nWeek_ban_mean = mean( repair_pop_nWeek_ban );
repair_pop_nWeek_quant_ban = quantile(repair_pop_nWeek_ban_mean, 1- worst_ratio_samp);
dm.repair_nWeek_all_worst_samp_ban = mean( repair_pop_nWeek_ban_mean( repair_pop_nWeek_ban_mean > repair_pop_nWeek_quant_ban ) );

repair_pop_nWeek_noban_mean_pop = mean( repair_pop_nWeek_noban, 2 );
repair_pop_nWeek_pop_quant_noban = quantile( repair_pop_nWeek_noban_mean_pop, 1-worst_ratio_pop );
dm.repair_nWeek_all_worst_pop_noban = mean( repair_pop_nWeek_noban_mean_pop( repair_pop_nWeek_noban_mean_pop > repair_pop_nWeek_pop_quant_noban ) );

repair_pop_nWeek_ban_mean_pop = mean( repair_pop_nWeek_ban, 2 );
repair_pop_nWeek_pop_quant_ban = quantile( repair_pop_nWeek_ban_mean_pop, 1-worst_ratio_pop );
dm.repair_nWeek_all_worst_pop_ban = mean( repair_pop_nWeek_ban_mean_pop( repair_pop_nWeek_ban_mean_pop > repair_pop_nWeek_pop_quant_ban ) );

% Well-being loss
wbl_income_sum_quant_noban = quantile( wbl_income_sum_noban, 1 - worst_ratio_samp );
dm.wbl_worst_samp_noban = mean( wbl_income_sum_noban( wbl_income_sum_noban > wbl_income_sum_quant_noban ) );

wbl_income_sum_quant_ban = quantile( wbl_income_sum_ban, 1 - worst_ratio_samp );
dm.wbl_income_worst_samp_ban = mean( wbl_income_sum_ban( wbl_income_sum_ban > wbl_income_sum_quant_ban ) );

wbl_supply_sum_quant_ban = quantile( wbl_supply_sum_ban, 1 - worst_ratio_samp );
dm.wbl_supply_worst_samp_ban = mean( wbl_supply_sum_ban( wbl_supply_sum_ban > wbl_supply_sum_quant_ban ) );

wbl_sum_ban = wbl_income_sum_ban + wbl_supply_sum_ban;
wbl_sum_quant_ban = quantile( wbl_sum_ban, 1 - worst_ratio_samp );
dm.wbl_worst_samp_ban = mean( wbl_sum_ban( wbl_sum_ban > wbl_sum_quant_ban ) );

wbl_income_noban_pop = cell2mat( cellfun( @sum, wbl_pop_income_hist_noban, 'UniformOutput', false ) );
wbl_income_noban_pop_quant = quantile( wbl_income_noban_pop, 1 - worst_ratio_pop );
dm.wbl_worst_pop_noban = mean( wbl_income_noban_pop( wbl_income_noban_pop > wbl_income_noban_pop_quant ) );

wbl_income_ban_pop = cell2mat( cellfun( @sum, wbl_pop_income_hist_ban, 'UniformOutput', false ) );
wbl_income_ban_pop_quant = quantile( wbl_income_ban_pop, 1 - worst_ratio_pop );
dm.wbl_income_worst_pop_ban = mean( wbl_income_ban_pop( wbl_income_ban_pop > wbl_income_ban_pop_quant ) );

wbl_supply_ban_pop = cell2mat( cellfun( @sum, wbl_pop_supply_hist_ban, 'UniformOutput', false ) );
wbl_supply_ban_pop_quant = quantile( wbl_supply_ban_pop, 1 - worst_ratio_pop );
dm.wbl_supply_worst_pop_ban = mean( wbl_supply_ban_pop( wbl_supply_ban_pop > wbl_supply_ban_pop_quant ) );

wbl_ban_pop = wbl_income_ban_pop + wbl_supply_ban_pop;
wbl_ban_pop_quant = quantile( wbl_ban_pop, 1 - worst_ratio_pop );
dm.wbl_worst_pop_ban = mean( wbl_ban_pop( wbl_ban_pop > wbl_ban_pop_quant ) );