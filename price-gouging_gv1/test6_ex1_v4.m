%{
Created: 30 April 2023
Ji-Eun Byun

Set up small examples for calibration
"v2": Merge parameters between basic goods and repair
+"v3": dynamic analysis
+"v4": Monte Carlo
%}

rng(2)

nPop = 5;
income_pop = [1 2 3.5 4.5 8];
repair_pop = [3 5 10 15 20];
repair_pop_std = [3 5 10 15 20];
income_min = 1;
dem_min = 0.9; % Min. demand given a minimum income
dem_inc_income = 0.4; % Increase in demand per increase in income
dem_max = 3; % Maximum demand
dem_orig_fun = @(incomes) arrayfun( @(income1) min([dem_max, dem_min + dem_inc_income*(income1-income_min)]), incomes, 'UniformOutput', true );

dem_pop_orig = dem_orig_fun(income_pop);

% Price cap
pcap = 0.5;

% Supply-price curve 
nWeek_disrup  = 12;
nWeek_disrup_cov = 1;

delP = 0.3; % Increase in production cost (ratio)
delP_cov = 1;
delP_g = 0.4; % Increase  by price-gouging (ratio)
delP_g_cov = 1;
delQ_b = 0.3; % Increase in demand for basic goods (ratio)
delQ_b_cov = 1;

QP_slope_b = 1;
QP_slope_b_cov = 1;

QP_slope_r = QP_slope_b/(0.1*sum(income_pop)); % sum(income_pop) is used to make it insensitive to the size of population
QP_slope_r_cov = QP_slope_b_cov;

delQ_b_sup_min = -0.95; % lower bound of supply (>-1)

delQ_r_sup_min = 0.05; % lower bound of supply (>0 as there is no originial consumption assumed)
delQ_r_normal = 0.05 * sum( repair_pop ); % this amount of demand is expected in normality

% Well-being loss
w0 = 0.75; % the well-being ratio that the fulfilment of minimum demand is met (in [0,1])

% etc.
Q_hd_b = 0.3; % increase in demand for basic goods because of hoarding
don = 0.0; % donation ratio of remaining income
nMCS = 1e4;

%% Dynamic analysis + Monte Carlo
dem_lack_abs_hist_noban = cell(nMCS,1); wbl_pop_income_hist_noban =  cell(nMCS,1); repair_pop_nWeek_noban = zeros(nPop, nMCS);
dem_lack_abs_hist_ban =  cell(nMCS,1); wbl_pop_income_hist_ban =  cell(nMCS,1); wbl_pop_supply_hist_ban =  cell(nMCS,1); repair_pop_nWeek_ban = zeros(nPop, nMCS);

% Monte Carlo
for iMCS = 1:nMCS
    disp( ['Sample ' num2str(iMCS) ' ..'] )
    repair_pop_m = repair_pop + randn( 1, nPop ) .* repair_pop_std;
    repair_pop_m( repair_pop_m < 0 ) = 0;
    
    nWeek_disrup_m = max([0, nWeek_disrup + randn * nWeek_disrup_cov * nWeek_disrup]);
    
    delP_m = max([0, delP + randn * delP_cov * delP]);
    delP_g_m = max([0, delP_g + randn * delP_g_cov * delP_g]);
    delQ_b_m = max([0, delQ_b + randn * delQ_b_cov * delQ_b]);
    QP_slope_b_m = max([0.1*QP_slope_b, QP_slope_b + randn * QP_slope_b_cov * QP_slope_b]);
    QP_slope_r_m = max([0.1*QP_slope_r, QP_slope_r + randn * QP_slope_b_cov * QP_slope_r]);
    
    % Dynamic analysis
    income_pop_rem_noban = income_pop;
    repair_pop_rem_noban = repair_pop_m;
    
    income_pop_rem_ban = income_pop;
    repair_pop_rem_ban = repair_pop_m;
    
    dem_lack_abs_hist_noban_t = zeros(0,1); wbl_pop_income_hist_noban_t = zeros(0,nPop); repair_pop_nWeek_noban_t = zeros(nPop, 1);
    dem_lack_abs_hist_ban_t = zeros(0,1); wbl_pop_income_hist_ban_t = zeros(0,nPop); wbl_pop_supply_hist_ban_t = zeros(0,nPop); repair_pop_nWeek_ban_t = zeros(nPop, 1);
    nWeek = 0;
    while sum( repair_pop_rem_noban ) || sum( repair_pop_rem_ban )
    
        nWeek = nWeek+1;
    
        delP_t = max([0, delP_m * ( (nWeek_disrup - nWeek + 1) / nWeek_disrup )]);
        delP_g_t = max([0, delP_g_m * ( (nWeek_disrup - nWeek + 1) / nWeek_disrup )]);
        delQ_b_t = max([0, delQ_b_m * ( (nWeek_disrup - nWeek + 1) / nWeek_disrup )]);
        Q_hd_b_t = max([0, Q_hd_b * ( (nWeek_disrup - nWeek + 1) / nWeek_disrup )]);
    
        if sum( repair_pop_rem_noban ) > 0
            [dem_lack_abs_noban, wbl_pop_income_noban, wbl_pop_supply_noban, repair_pop_rem_noban, income_pop_rem_noban] = gg_v2.sim_no_cap( income_pop_rem_noban + income_pop, repair_pop_rem_noban, dem_pop_orig, delP_t, delP_g_t, delQ_b_t, QP_slope_b_m, w0, dem_min, income_pop, QP_slope_r_m, delQ_r_normal, don );
        
            dem_lack_abs_hist_noban_t = [dem_lack_abs_hist_noban_t; dem_lack_abs_noban];
            wbl_pop_income_hist_noban_t = [wbl_pop_income_hist_noban_t; wbl_pop_income_noban];
            repair_pop_nWeek_noban_t( (repair_pop(:)>0) & ~repair_pop_nWeek_noban_t(:) & ~repair_pop_rem_noban(:) ) = nWeek;
        end
    
        if sum( repair_pop_rem_ban ) > 0
            [dem_lack_abs_ban, wbl_pop_income_ban, wbl_pop_supply_ban, repair_pop_rem_ban, income_pop_rem_ban] = gg_v2.sim_yes_cap( income_pop_rem_ban + income_pop, repair_pop_rem_ban, dem_pop_orig, delP_t, delP_g_t, delQ_b_t, QP_slope_b_m, w0, dem_min, income_pop, QP_slope_r_m, delQ_r_normal, don, pcap, Q_hd_b_t, delQ_b_sup_min, delQ_r_sup_min );
           
            dem_lack_abs_hist_ban_t = [dem_lack_abs_hist_ban_t; dem_lack_abs_ban];
            wbl_pop_income_hist_ban_t = [wbl_pop_income_hist_ban_t; wbl_pop_income_ban];
            wbl_pop_supply_hist_ban_t = [wbl_pop_supply_hist_ban_t; wbl_pop_supply_ban];
            repair_pop_nWeek_ban_t( (repair_pop(:)>0) & ~repair_pop_nWeek_ban_t(:) & ~repair_pop_rem_ban(:) ) = nWeek;
        end
    
    end

    dem_lack_abs_hist_noban{iMCS} = dem_lack_abs_hist_noban_t;
    wbl_pop_income_hist_noban{iMCS} = wbl_pop_income_hist_noban_t;
    repair_pop_nWeek_noban(:,iMCS) = repair_pop_nWeek_noban_t;

    dem_lack_abs_hist_ban{iMCS} = dem_lack_abs_hist_ban_t;
    wbl_pop_income_hist_ban{iMCS} = wbl_pop_income_hist_ban_t;
    wbl_pop_supply_hist_ban{iMCS} = wbl_pop_supply_hist_ban_t;
    repair_pop_nWeek_ban(:,iMCS) = repair_pop_nWeek_ban_t;

    disp( ['[Max. weeks for complete repair] No ban: ' num2str(max(repair_pop_nWeek_noban_t)) ', Ban: ' num2str(max(repair_pop_nWeek_ban_t))] )

end

%% Decision metrics
run test6_decision.m

