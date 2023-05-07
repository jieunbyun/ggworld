function [dem_lack_abs, wbl_pop_income, wbl_pop_supply, repair_pop_rem_new, income_pop_rem_new] = sim_yes_cap( income_pop_rem, repair_pop_rem, dem_pop_orig, delP, delP_g, delQ_b, QP_slope_b, w0, dem_min, income_pop, QP_slope_r, delQ_r_normal, don, pcap, Q_hd_b, delQ_b_sup_min, delQ_r_sup_min )

% % Basic goods
% Price increase 
delP_b_new = delP + delQ_b * QP_slope_b;
if delP_b_new > pcap
    delP_b_new = pcap;
    supply_b_new = max([delQ_b_sup_min, (delP_b_new - delP) / QP_slope_b]); 
else
    delP_b_new = min( [delP_b_new + delP_g, pcap] ); % When there is a margin for price-gouging, it occurs by the margin.
    supply_b_new = delQ_b;
end

% New price 
dem_pop_new = (1+delP_b_new) * (1 + delQ_b + Q_hd_b) * dem_pop_orig;
dem_pop_afford = dem_pop_new; dem_pop_afford( dem_pop_new > income_pop_rem ) = income_pop_rem( dem_pop_new > income_pop_rem );

% How much can be supplied to each person
sup_pop_new = (1+delP_b_new) * (1+supply_b_new) / (1 + delQ_b + Q_hd_b) * dem_pop_orig;
sup_new_sum = sum(sup_pop_new);
sup_new_lack = sum(dem_pop_afford) - sup_new_sum;
if sup_new_lack > 0
    % Redistribute the supply unused by people who cannot afford
    dem_pop_actual = sup_pop_new;
    while any( dem_pop_actual > dem_pop_afford )
        pops_over = (dem_pop_actual > dem_pop_afford);
        pops_under = (dem_pop_actual < dem_pop_afford);

        pops_under_remaining = dem_pop_afford(pops_under) - dem_pop_actual(pops_under);
        dem_pop_actual( pops_under ) = dem_pop_actual( pops_under ) + sum( dem_pop_actual( pops_over )-dem_pop_afford( pops_over ) ) * (pops_under_remaining / sum( pops_under_remaining ) );
        dem_pop_actual( pops_over ) = dem_pop_afford( pops_over );
    end

else    
    % No need to redistribute as there is enough supply
    dem_pop_actual = dem_pop_afford;
end

% Shortage due to income lack
% Absolute term
dem_lack_pop = dem_pop_new-dem_pop_actual; 
dem_lack_abs = sum(dem_lack_pop); % This is the quantity that needs to be provided by the government: This quantity is evaluated with regard to the increased price and quantity.

% Well-being loss
wbl_pop = gg_v2.eval_wbl( w0, dem_min ./ ( dem_pop_orig * (1+Q_hd_b) ), 1-dem_lack_pop./dem_pop_new );
wbl_pop_income = wbl_pop .* (dem_pop_new-dem_pop_afford) ./ dem_lack_pop; % proportionate blamed to income lack and supply
wbl_pop_income(~dem_lack_pop) = 0;
wbl_pop_supply = wbl_pop .* (dem_pop_afford-dem_pop_actual) ./ dem_lack_pop; 
wbl_pop_supply(~dem_lack_pop) = 0;

% Remaining income (to calculate repair)
income_pop_rem_new = income_pop_rem - dem_pop_new; income_pop_rem_new(income_pop_rem_new<0) = 0; % we assume that the government provides insufficient goods with the fixed price. This is not to double-count the effect of price cap (i.e. it will expedite repair process if people use income for repair with the money left because they could not fulfil their basic needs because of insufficient supply.)


% % Repair
% New demand and quantity
repair_pop_dem = income_pop_rem_new; repair_pop_dem( repair_pop_rem < income_pop_rem_new ) = repair_pop_rem( repair_pop_rem < income_pop_rem_new );
Q_r = sum(repair_pop_dem);
delP_r_new = delP + max([0,(Q_r-delQ_r_normal)])*QP_slope_r;

if delP_r_new > pcap
    delP_r_new = pcap;
    supply_r_new = max([delQ_r_sup_min, (delP_r_new - delP) / QP_slope_r]); 
else
    delP_r_new = min( [delP_r_new + delP_g, pcap] ); % When there is a margin for price-gouging, it occurs by the margin.
    supply_r_new = 1;
end

% How much can be supplied to each person
sup_pop_new = (1+delP_r_new) * supply_r_new * repair_pop_dem;
sup_new_sum = sum(sup_pop_new);
sup_new_lack = sum(repair_pop_dem) - sup_new_sum;
if sup_new_lack > 0
    % Redistribute the supply unused by people who cannot afford
    dem_pop_actual = sup_pop_new;
    while any( dem_pop_actual > repair_pop_dem )
        pops_over = (dem_pop_actual > repair_pop_dem);
        pops_under = (dem_pop_actual < repair_pop_dem);

        pops_under_remaining = repair_pop_dem(pops_under) - dem_pop_actual(pops_under);
        dem_pop_actual( pops_under ) = dem_pop_actual( pops_under ) + sum( dem_pop_actual( pops_over )-repair_pop_dem( pops_over ) )  .* ( pops_under_remaining / sum( pops_under_remaining ) );
        dem_pop_actual( pops_over ) = repair_pop_dem( pops_over );
    end

else    
    % No need to redistribute as there is enough supply
    dem_pop_actual = repair_pop_dem;
end

% Adjust remianing income by new price
income_pop_rem_new_adj = income_pop_rem_new / (1+delP_r_new);

% Do repair
repair_pop = income_pop_rem_new_adj; repair_pop( dem_pop_actual < income_pop_rem_new_adj ) = dem_pop_actual( dem_pop_actual < income_pop_rem_new_adj );
repair_pop_rem_new = repair_pop_rem - repair_pop; repair_pop_rem_new( repair_pop_rem_new<0 ) = 0;

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