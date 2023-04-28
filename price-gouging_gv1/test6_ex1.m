%{
Created: 28 April 2023
Ji-Eun Byun

Set up small examples to calibrate the model
%}

nPop = 5;
income_pop = [1 2 3.5 4.5 6];
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

% Repair, denoted by "_r"
delP_r = 0.3; % Increase in production cost (ratio)
delP_g_r = 0.4; % Increase  by price-gouging (ratio)
QP_slope_r = 0.5;
Q_orig_r = sum(income_pop)*0.5;

% Well-being loss
w0 = 0.75; % the well-being ratio that the fulfilment of minimum demand is met (in [0,1])


%% No cap
% % Basic goods
% Price increase 
delP_b = delP_b + delP_g_b + delQ_b*QP_slope_b;

% New price 
dem_pop_new = (1+delP_b) * dem_pop_orig;

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
delP_r = delP_r + delP_g_r + delQ_r*QP_slope_r;

% Adjust remianing income by new price
income_rem_pop_new = income_rem_pop / (1+delP_r);

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