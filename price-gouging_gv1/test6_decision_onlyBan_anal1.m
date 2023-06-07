%% Total averages

% Total lack of basic goods (absolute price) -- this is what needs to be deli
dm.basic_shortage_all_ban = mean( dem_lack_abs_sum_ban );
dm.basic_shortage_all_std_ban = std( dem_lack_abs_sum_ban );

% Mean number or weeks for repair
dm.repair_nWeek_all_ban = mean( mean_repair_pop_nWeek_ban );
dm.repair_nWeek_all_std_ban = std(mean_repair_pop_nWeek_ban );

% Well-being loss
dm.wbl_income_all_ban = mean( wbl_income_sum_ban );
dm.wbl_income_all_std_ban = std( wbl_income_sum_ban );

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
dm.repair_nWeek_all_worst_pop_ban = mean(repair_pop_nWeek_pop_quant_ban);
dm.repair_nWeek_all_worst_pop_std_ban = std(repair_pop_nWeek_pop_quant_ban);

pop_inds_worst_nWeek_income_mat = cell2mat( pop_inds_worst_nWeek_income' );
dm.repair_nWeek_all_worst_pop_ban_income_mean = mean( pop_inds_worst_nWeek_income_mat );
dm.repair_nWeek_all_worst_pop_ban_income_std = std( pop_inds_worst_nWeek_income_mat );

pop_inds_worst_nWeek_repair_mat = cell2mat(pop_inds_worst_nWeek_repair');
dm.repair_nWeek_all_worst_pop_ban_repair_mean = mean( pop_inds_worst_nWeek_repair_mat );
dm.repair_nWeek_all_worst_pop_ban_repair_std = std( pop_inds_worst_nWeek_repair_mat );

dm.repair_nWeek_all_worst_pop_ban_rat_mean = mean( pop_inds_worst_nWeek_repair_mat ./ pop_inds_worst_nWeek_income_mat );
dm.repair_nWeek_all_worst_pop_ban_rat_std = std( pop_inds_worst_nWeek_repair_mat ./ pop_inds_worst_nWeek_income_mat );


repair_pop_nWeek_sam_quant_ban = quantile( repair_pop_nWeek_ban', 1-worst_ratio_pop );
dm.repair_nWeek_all_worst_sam_ban = mean(repair_pop_nWeek_sam_quant_ban);
dm.repair_nWeek_all_worst_sam_std_ban = std(repair_pop_nWeek_sam_quant_ban);

%
% WBL-income
%

% wbl_income_ban_pop_quant = quantile( wbl_income_ban_pop, 1 - worst_ratio_pop );
dm.wbl_income_worst_pop_ban = mean(wbl_income_ban_pop_quant);
dm.wbl_income_worst_pop_std_ban = std(wbl_income_ban_pop_quant);

pop_inds_worst_wbl_income_income_mat = cell2mat( pop_inds_worst_wbl_income_income' );
dm.wbl_income_ban_pop_income_mean = mean( pop_inds_worst_wbl_income_income_mat );
dm.wbl_income_ban_pop_income_std = std( pop_inds_worst_wbl_income_income_mat );

pop_inds_worst_wbl_income_repair_mat = cell2mat(pop_inds_worst_wbl_income_repair');
dm.wbl_income_ban_pop_repair_mean = mean( pop_inds_worst_wbl_income_repair_mat );
dm.wbl_income_ban_pop_repair_std = std( pop_inds_worst_wbl_income_repair_mat );

dm.wbl_income_ban_pop_ban_rat_mean = mean( pop_inds_worst_wbl_income_repair_mat ./ pop_inds_worst_wbl_income_income_mat );
dm.wbl_income_ban_pop_ban_rat_std = std( pop_inds_worst_wbl_income_repair_mat ./ pop_inds_worst_wbl_income_income_mat );


wbl_income_ban_sam_quant = quantile( wbl_income_ban_pop', 1 - worst_ratio_pop );
dm.wbl_income_worst_sam_ban = mean(wbl_income_ban_sam_quant);
dm.wbl_income_worst_sam_std_ban = std(wbl_income_ban_sam_quant);

%
% WBL-supply
%

% wbl_supply_ban_pop_quant = quantile( wbl_supply_ban_pop, 1 - worst_ratio_pop );
dm.wbl_supply_worst_pop_ban = mean(wbl_supply_ban_pop_quant);
dm.wbl_supply_worst_pop_std_ban = std(wbl_supply_ban_pop_quant);

pop_inds_worst_wbl_supply_income_mat = cell2mat( pop_inds_worst_wbl_supply_income' );
dm.wbl_supply_ban_pop_income_mean = mean( pop_inds_worst_wbl_supply_income_mat );
dm.wbl_supply_ban_pop_income_std = std( pop_inds_worst_wbl_supply_income_mat );

pop_inds_worst_wbl_supply_repair_mat = cell2mat(pop_inds_worst_wbl_supply_repair');
dm.wbl_supply_ban_pop_repair_mean = mean( pop_inds_worst_wbl_supply_repair_mat );
dm.wbl_supply_ban_pop_repair_std = std( pop_inds_worst_wbl_supply_repair_mat );

dm.wbl_supply_ban_pop_ban_rat_mean = mean( pop_inds_worst_wbl_supply_repair_mat ./ pop_inds_worst_wbl_supply_income_mat );
dm.wbl_supply_ban_pop_ban_rat_std = std( pop_inds_worst_wbl_supply_repair_mat ./ pop_inds_worst_wbl_supply_income_mat );

wbl_supply_ban_sam_quant = quantile( wbl_supply_ban_pop', 1 - worst_ratio_pop );
dm.wbl_supply_worst_sam_ban = mean(wbl_supply_ban_sam_quant);
dm.wbl_supply_worst_sam_std_ban = std(wbl_supply_ban_sam_quant);

%
% WBL-supply
%

% dem_lack_ban_pop_quant = quantile( dem_lack_ban_pop, 1 - worst_ratio_pop );
dm.dem_lack_worst_pop_ban = mean(dem_lack_ban_pop_quant);
dm.dem_lack_worst_pop_std_ban = std(dem_lack_ban_pop_quant);

pop_inds_worst_dem_lack_income_mat = cell2mat( pop_inds_worst_dem_lack_income' );
dm.dem_lack_ban_pop_income_mean = mean( pop_inds_worst_dem_lack_income_mat );
dm.dem_lack_ban_pop_income_std = std( pop_inds_worst_dem_lack_income_mat );

pop_inds_worst_dem_lack_repair_mat = cell2mat(pop_inds_worst_dem_lack_repair');
dm.dem_lack_ban_pop_repair_mean = mean( pop_inds_worst_dem_lack_repair_mat );
dm.dem_lack_ban_pop_repair_std = std( pop_inds_worst_dem_lack_repair_mat );

dm.dem_lack_ban_pop_ban_rat_mean = mean( pop_inds_worst_dem_lack_repair_mat ./ pop_inds_worst_dem_lack_income_mat );
dm.dem_lack_ban_pop_ban_rat_std = std( pop_inds_worst_dem_lack_repair_mat ./ pop_inds_worst_dem_lack_income_mat );


dem_lack_ban_sam_quant = quantile( dem_lack_ban_pop', 1 - worst_ratio_pop );
dm.dem_lack_worst_sam_ban = mean(dem_lack_ban_sam_quant);
dm.dem_lack_worst_sam_std_ban = std(dem_lack_ban_sam_quant);
