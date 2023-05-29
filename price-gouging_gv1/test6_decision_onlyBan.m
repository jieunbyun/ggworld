%% Total averages

% Total lack of basic goods (absolute price) -- this is what needs to be deli
dem_lack_abs_sum.ban = cellfun( @sum, dem_lack_abs_hist_ban ) / nPop;
dm.basic_shortage_all_ban = mean( dem_lack_abs_sum.ban);
dm.basic_shortage_all_std_ban = std( dem_lack_abs_sum.ban );

% Mean number or weeks for repair
mean_repair_pop_nWeek_ban = mean(repair_pop_nWeek_ban, 1);
dm.repair_nWeek_all_ban = mean( mean_repair_pop_nWeek_ban );
dm.repair_nWeek_all_std_ban = std(mean_repair_pop_nWeek_ban );

% Well-being loss
wbl_income_sum_ban = cellfun( @(x) mean(sum(x)), wbl_pop_income_hist_ban );
dm.wbl_income_all_ban = mean( wbl_income_sum_ban );
dm.wbl_income_all_std_ban = std( wbl_income_sum_ban );

wbl_supply_sum_ban = cellfun( @(x) mean(sum(x)), wbl_pop_supply_hist_ban );
dm.wbl_supply_all_ban = mean( wbl_supply_sum_ban );
dm.wbl_supply_all_std_ban = std( wbl_supply_sum_ban );

% dm.wbl_all_ban = dm.wbl_income_all_ban + dm.wbl_supply_all_ban;
% dm.wbl_all_std_ban = std( wbl_supply_sum_ban + wbl_income_sum_ban);
% dm.wbl_all_95worst_ban = prctile( wbl_supply_sum_ban + wbl_income_sum_ban,95);

%% Worst scenarios
% TODO: look at only 95% person
worst_ratio_samp = 0.05; worst_ratio_pop = 0.05;

%
% Repair
%

repair_pop_nWeek_pop_quant_ban = quantile( repair_pop_nWeek_ban, 1-worst_ratio_pop );
dm.repair_nWeek_all_worst_pop_ban = mean(repair_pop_nWeek_pop_quant_ban);
dm.repair_nWeek_all_worst_pop_std_ban = std(repair_pop_nWeek_pop_quant_ban);

repair_pop_nWeek_sam_quant_ban = quantile( repair_pop_nWeek_ban', 1-worst_ratio_pop );
dm.repair_nWeek_all_worst_sam_ban = mean(repair_pop_nWeek_sam_quant_ban);
dm.repair_nWeek_all_worst_sam_std_ban = std(repair_pop_nWeek_sam_quant_ban);

%
% WBL-income
%

wbl_income_ban_pop = cell2mat( cellfun( @sum, wbl_pop_income_hist_ban, 'UniformOutput', false ) )';
wbl_income_ban_pop_quant = quantile( wbl_income_ban_pop, 1 - worst_ratio_pop );
dm.wbl_income_worst_pop_ban = mean(wbl_income_ban_pop_quant);
dm.wbl_income_worst_pop_std_ban = std(wbl_income_ban_pop_quant);

wbl_income_ban_sam_quant = quantile( wbl_income_ban_pop', 1 - worst_ratio_pop );
dm.wbl_income_worst_sam_ban = mean(wbl_income_ban_sam_quant);
dm.wbl_income_worst_sam_std_ban = std(wbl_income_ban_sam_quant);

%
% WBL-supply
%

wbl_supply_ban_pop = cell2mat( cellfun( @sum, wbl_pop_supply_hist_ban, 'UniformOutput', false ) )';
wbl_supply_ban_pop_quant = quantile( wbl_supply_ban_pop, 1 - worst_ratio_pop );
dm.wbl_supply_worst_pop_ban = mean(wbl_supply_ban_pop_quant);
dm.wbl_supply_worst_pop_std_ban = std(wbl_supply_ban_pop_quant);

wbl_supply_ban_sam_quant = quantile( wbl_supply_ban_pop', 1 - worst_ratio_pop );
dm.wbl_supply_worst_sam_ban = mean(wbl_supply_ban_sam_quant);
dm.wbl_supply_worst_sam_std_ban = std(wbl_supply_ban_sam_quant);

%
% WBL-supply
%

dem_lack_ban_pop = cell2mat( cellfun( @sum, dem_lack_pop_hist_ban, 'UniformOutput', false ) )';
dem_lack_ban_pop_quant = quantile( dem_lack_ban_pop, 1 - worst_ratio_pop );
dm.dem_lack_worst_pop_ban = mean(dem_lack_ban_pop_quant);
dm.dem_lack_worst_pop_std_ban = std(dem_lack_ban_pop_quant);

dem_lack_ban_sam_quant = quantile( dem_lack_ban_pop', 1 - worst_ratio_pop );
dm.dem_lack_worst_sam_ban = mean(dem_lack_ban_sam_quant);
dm.dem_lack_worst_sam_std_ban = std(dem_lack_ban_sam_quant);
