%{
Created: 28 April 2023
Ji-Eun Byun

Set up small examples for calibration
%}

nPop = 5;
income_pop = [1 2 3.5 4.5 8];
repair_pop = [3 0 6 0 20];
income_min = 1;
dem_min = 0.9; % Min. demand given a minimum income
dem_inc_income = 0.4; % Increase in demand per increase in income
dem_max = 3; % Maximum demand
dem_orig_fun = @(incomes) arrayfun( @(income1) min([dem_max, dem_min + dem_inc_income*(income1-income_min)]), incomes, 'UniformOutput', true );

dem_pop_orig = dem_orig_fun(income_pop);

% Basic goods, denoted by "_b"
delP_b = 0.3; % Increase in production cost (ratio)
delP_g_b = 0.4; % Increase  by price-gouging (ratio)
delQ_b = 0.3; % Increase in demand (ratio)
QP_slope_b = 1;
Q_orig_b = sum( dem_pop_orig );
delQ_b_sup_min = -0.95; % lower bound of supply (>-1)

% Repair, denoted by "_r"
delP_r = 0.3; % Increase in production cost (ratio)
delP_g_r = 0.4; % Increase  by price-gouging (ratio)
QP_slope_r = 0.5;
% Q_orig_r = sum(income_pop)*0.1; % How about going without this, assuming that any need for repair by earthquake is excessive?
delQ_r_sup_min = 0.05; % lower bound of supply (>0 as there is no originial consumption assumed)
delQ_div = 0.1; % To make it insensivite to the number of population, delQ is set as Q_r / (income_sum * delQ_div)

% Well-being loss
w0 = 0.75; % the well-being ratio that the fulfilment of minimum demand is met (in [0,1])

% etc.



%% No cap
% % Basic goods
% Price increase 
delP_b_new = delP_b + delP_g_b + delQ_b*QP_slope_b;

% New price 
dem_pop_new = (1+delP_b_new) * (1 + delQ_b) * dem_pop_orig;

% Shortage due to income lack
% Absolute term
dem_lack_pop = dem_pop_new-income_pop; dem_lack_pop(dem_lack_pop<0) = 0;
dem_lack_abs = sum(dem_lack_pop); % This is the quantity that needs to be provided by the government: This quantity is evaluated with regard to the increased price and quantity.

% Well-being loss
wbl_pop = gg_v2.eval_wbl( w0, dem_min./dem_pop_orig, 1-dem_lack_pop./dem_pop_new );
wbl_pop_income = wbl_pop;
wbl_pop_supply = zeros(size(wbl_pop)); % There is no lack of supply

% Remaining income (to calculate repair)
income_rem_pop = income_pop-dem_pop_new; income_rem_pop(income_rem_pop<0) = 0;


% % Repair
% Increase in demand and quantity
delQ_r = sum(repair_pop) / Q_orig_r - 1;
delP_r_new = delP_r + delP_g_r + delQ_r*QP_slope_r;

% Adjust remianing income by new price
income_rem_pop_new = income_rem_pop / (1+delP_r_new);

% Do repair
repair_pop_update = repair_pop - income_rem_pop_new; repair_pop_update(repair_pop_update<0) = 0;


% Without a price cap (i.e. sufficient supply always), there is no remaining income to be carried over next.
income_rem_update = zeros(size(income_pop));


% % Record
result.dem_lack_abs = dem_lack_abs;
result.wbl_income = wbl_pop_income;
result.wbl_supply = wbl_pop_supply;

result.repair_rem = repair_pop_update;
result.income_rem = income_rem_update;

%% With cap
price_cap = 0.5;

% % Basic goods
% Price increase 
delP_b_new = delP_b + delQ_b*QP_slope_b;
if delP_b_new > price_cap
    delP_b_new = price_cap;
    supply_b_new = max([delQ_b_sup_min, (delP_b_new - delP_b) / QP_slope_b]); 
else
    delP_b_new = min( [delP_b_new + delP_g_b, price_cap] ); % When there is a margin for price-gouging, it occurs by the margin.
    supply_b_new = delQ_b;
end

% New price 
dem_pop_new = (1+delP_b_new) * (1 + delQ_b) * dem_pop_orig;
dem_pop_afford = dem_pop_new; dem_pop_afford( dem_pop_new > income_pop ) = income_pop( dem_pop_new > income_pop );

% How much can be supplied to each person
sup_pop_new = (1+delP_b_new) * (1+supply_b_new) / (1 + delQ_b) * dem_pop_orig;
sup_new_sum = sum(sup_pop_new);
sup_new_lack = sum(dem_pop_afford) - sup_new_sum;
if sup_new_lack > 0
    % Redistribute the supply unused by people who cannot afford
    dem_pop_actual = sup_pop_new;
    while any( dem_pop_actual > dem_pop_afford )
        pops_over = (dem_pop_actual > dem_pop_afford);
        pops_under = (dem_pop_actual < dem_pop_afford);

        dem_pop_actual( pops_under ) = dem_pop_actual( pops_under ) + sum( dem_pop_actual( pops_over )-dem_pop_afford( pops_over ) ) / sum( pops_under );
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
wbl_pop = gg_v2.eval_wbl( w0, dem_min./dem_pop_orig, 1-dem_lack_pop./dem_pop_new );
wbl_pop_income = wbl_pop .* (dem_pop_new-dem_pop_afford) ./ dem_lack_pop; % proportionate blame to income lack and supply
wbl_pop_supply = wbl_pop .* (dem_pop_afford-dem_pop_actual) ./ dem_lack_pop; 

% Remaining income (to calculate repair)
income_rem_pop = income_pop - dem_pop_new; income_rem_pop(income_rem_pop<0) = 0; % we assume that the government provides insufficient goods with the fixed price. This is not to double-count the effect of price cap (i.e. it will expedite repair process if people use income for repair with the money left because they could not fulfil their basic needs because of insufficient supply.)

% % Repair
% New demand and quantity
repair_pop_dem = income_rem_pop; repair_pop_dem( repair_pop < income_rem_pop ) = repair_pop( repair_pop < income_rem_pop );
Q_r = sum(repair_pop_dem);

delP_r_new = delP_r + Q_r*QP_slope_r / sum(income_pop) / delQ_div;
if delP_r_new > price_cap
    delP_r_new = price_cap;
    supply_r_new = max([delQ_r_sup_min, (delP_r_new - delP_r) / QP_slope_r * ( sum(income_pop) * delQ_div )]); 
else
    delP_r_new = min( [delP_r_new + delP_g_r, price_cap] ); % When there is a margin for price-gouging, it occurs by the margin.
    supply_r_new = Q_r;
end

% How much can be supplied to each person
sup_pop_new = (1+delP_r_new) * supply_r_new / Q_r * repair_pop_dem;
sup_new_sum = sum(sup_pop_new);
sup_new_lack = sum(repair_pop_dem) - sup_new_sum;
if sup_new_lack > 0
    % Redistribute the supply unused by people who cannot afford
    dem_pop_actual = sup_pop_new;
    while any( dem_pop_actual > repair_pop_dem )
        pops_over = (dem_pop_actual > repair_pop_dem);
        pops_under = (dem_pop_actual < repair_pop_dem);

        dem_pop_actual( pops_under ) = dem_pop_actual( pops_under ) + sum( dem_pop_actual( pops_over )-repair_pop_dem( pops_over ) ) / sum( pops_under );
        dem_pop_actual( pops_over ) = repair_pop_dem( pops_over );
    end

else    
    % No need to redistribute as there is enough supply
    dem_pop_actual = repair_pop_dem;
end

% Adjust remianing income by new price
repair_pop_dem_new = dem_pop_actual / (1+delP_r);

% Do repair
repair_pop_update = repair_pop - repair_pop_dem_new; repair_pop_update(repair_pop_update<0) = 0;


% Without a price cap (i.e. sufficient supply always), there is no remaining income to be carried over next.
income_rem_update = income_rem_pop - dem_pop_actual;


% % Record
result.dem_lack_abs = dem_lack_abs;
result.wbl_income = wbl_pop_income;
result.wbl_supply = wbl_pop_supply;

result.repair_rem = repair_pop_update;
result.income_rem = income_rem_update;