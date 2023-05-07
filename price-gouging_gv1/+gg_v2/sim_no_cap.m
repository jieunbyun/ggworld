function [dem_lack_abs, wbl_pop_income, wbl_pop_supply, repair_pop_rem_new, income_pop_rem_new] = sim_no_cap( income_pop_rem, repair_pop_rem, dem_pop_orig, delP, delP_g, delQ_b, QP_slope_r, w0, dem_min, income_pop, QP_slope_b, delQ_r_normal, don )

% % Basic goods
% Price increase 
delP_b_new = delP + delP_g + delQ_b*QP_slope_b;

% New price 
dem_pop_new = (1+delP_b_new) * (1 + delQ_b) * dem_pop_orig;

% Shortage due to income lack
% Absolute term
dem_lack_pop = dem_pop_new-income_pop_rem; dem_lack_pop(dem_lack_pop<0) = 0;
dem_lack_abs = sum(dem_lack_pop); % This is the quantity that needs to be provided by the government: This quantity is evaluated with regard to the increased price and quantity.

% Well-being loss
wbl_pop = gg_v2.eval_wbl( w0, dem_min./dem_pop_orig, 1-dem_lack_pop./dem_pop_new );
wbl_pop_income = wbl_pop;
wbl_pop_supply = zeros(size(wbl_pop)); % There is no lack of supply

% Remaining income (to calculate repair)
income_pop_rem_new = income_pop_rem-dem_pop_new; income_pop_rem_new(income_pop_rem_new<0) = 0;


% % Repair
% Increase in demand and quantity
repair_pop_dem = income_pop_rem_new; repair_pop_dem( repair_pop_rem < income_pop_rem_new ) = repair_pop_rem( repair_pop_rem < income_pop_rem_new );
Q_r = sum(repair_pop_dem);
delP_r_new = delP + delP_g + max([0,(Q_r-delQ_r_normal)])*QP_slope_r;

% Adjust remianing income by new price
income_pop_rem_new_adj = income_pop_rem_new / (1+delP_r_new);

% Do repair
repair_pop = income_pop_rem_new_adj; repair_pop( repair_pop_dem < income_pop_rem_new_adj ) = repair_pop_dem( repair_pop_dem < income_pop_rem_new_adj );
repair_pop_rem_new = repair_pop_rem - repair_pop; repair_pop_rem_new(repair_pop_rem_new<0) = 0;

% Remaining income to be carried over to the next time step
income_pop_rem_new = income_pop_rem_new - repair_pop * (1+delP_r_new); 

% Donation
if don > 0
    don_pop = (income_pop_rem_new > 0) & (~repair_pop_rem_new);
    if sum(don_pop) > 0
        to_be_don_pop = (repair_pop_rem_new > 0);
        income_pop_rem_new(to_be_don_pop) = income_pop_rem_new(to_be_don_pop) + sum( income_pop_rem_new(don_pop) ) * don / sum(don_pop);
        income_pop_rem_new(don_pop) = income_pop_rem_new(don_pop) * (1-don);
    end
end