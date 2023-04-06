%{
Created: 2 April 2023

test4_: Uncertainties in slopes
%}

clear all; 
rng(1);
vName = '_v4';

%% Data

R2D=load('R2D_data/R2Ddata.mat');

nPop = 1e4;
pop_inds = randsample( length(R2D.myMeanRepCost), nPop, false );
myWeeklyIncome = R2D.myWeeklyIncome(pop_inds)';
myLoss_mean = R2D.myMeanRepCost(pop_inds)';
myLoss_std = R2D.myStdRepCost(pop_inds)';
myMaxLoss = myWeeklyIncome*20;

%%% When things are peaceful %%%
simInput.tq_l = sum(myLoss_mean)*0.1; % total quantity in normality: "_l" stands for loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Model parameters %%%
% Normalised & additive (i.e. if it increases by 0.5, then it means the final price is 1.5 times the original one)
priceIncrease_b = 2; 
priceIncrease_l = priceIncrease_b;

simInput.dQd_b = 0.5; % Increased quantity demand after disaster - basic quantities: "_b" stands for basic living costs
simInput.dQd_b_cov = 0.2;
simInput.dPd_b = 0.3; % Increased supply price after disaster (ban has negative effects on long-term recovery until dPd_b > 0.7, when dPd_b == 0.5, there are some cases that ban has adverse effects.)
simInput.dPd_b_cov = 0.2;
simInput.SupSlope_b = 1; % A lower value means supply need to decrease quite a lot to meet the price cap -- it may result in ban having adverse effects. (e.g. such effect starts emerging when SupSlope_b <= 0.7 with prob. less than 3%).
% simInput.SupSlope_b_cov = 0.2; % Seems less uncertain than other parameters

simInput.dPd_l = simInput.dPd_b;
simInput.dPd_l_cov = 0.2;
simInput.SupSlope_l = simInput.SupSlope_b; 
% simInput.SupSlope_l_cov = 0.2; % Seems less uncertain than other parameters

simInput.pcap_b = 0.1; % Price cap for basic living. If less than "dPd_b", production decreases.
simInput.pcap_l = 0.1;

% Etc.
simInput.hoarding = 0;
simInput.donation = 0; 
%%%%%%%%%%%%%%%%%%%%%%

income_min = min(R2D.myWeeklyIncome); alp_min = 0.5; q_min = 0.9*min(R2D.myWeeklyIncome);
simInput.q_b_fun = @(incomes) min([q_min + alp_min * (incomes(:)') - income_min; 5*q_min*ones(1,length(incomes))], [], 1);

simInput.weeks_to_recover = 15; % Not anymore increase in basic quantity and supply price.
nSample = 1e2;

%% Case 1 Default
fname_out = 'default';
simInput.dPd_b_gg = priceIncrease_b - simInput.dPd_b; simInput.dPd_l_gg = priceIncrease_l - simInput.dPd_l; simInput.nWeek_gg = 15; % price-gouging rate
result_def = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput, fname_out, vName );
% --> The difference of the number of recovery weeks increases with (1) the upper cap of loss and (2) SupSlope_l.

%% Case 2-1 When pcap is too stringent compared to dPd
fname_out_hp = 'high_dPd';
simInput_hp = simInput;
simInput_hp.dPd_b = 1; 
simInput_hp.dPd_l = simInput_hp.dPd_b; 
simInput_hp.dPd_b_gg = priceIncrease_b-simInput_hp.dPd_b; simInput_hp.dPd_l_gg = priceIncrease_l-simInput_hp.dPd_l; 
result_hp = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_hp, fname_out_hp, vName );
% --> The number of recovery weeks with ban in place starts increasing when (pcap_l - dPd_l) / SupSlope_l < -0.98.

%% Case 2-2 Somewhere in between Case 1 and Case 2-1 
fname_out_mp = 'mid_dPd';
simInput_mp = simInput;
simInput_mp.dPd_b = 0.5*(simInput.dPd_b + simInput_hp.dPd_b); 
simInput_mp.dPd_l = simInput_mp.dPd_b; 
simInput_mp.dPd_b_gg = priceIncrease_b-simInput_mp.dPd_b; simInput_mp.dPd_l_gg = priceIncrease_l-simInput_mp.dPd_l; 
result_mp = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_mp, fname_out_mp, vName );

%% Case 3 Ban is not effective when there is not much loss 
% No critical information
%{
fname_out_ll = 'low_loss';
loss_coeff = 0.1;
myLoss_mean_ll = loss_coeff * myLoss_mean; myLoss_std_ll = loss_coeff * myLoss_std; myMaxLoss_ll = loss_coeff * myMaxLoss;
result_ll = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean_ll, myLoss_std_ll, myMaxLoss_ll, simInput, fname_out_ll, vName );
%}

%% Case 4 Ban is favoured when price gouging is high
% Message the same as Case 2
%{
fname_out_hg = 'high_goug';
simInput_hg = simInput;
simInput_hg.dPd_b_gg = 2*simInput_hg.dPd_b_gg;
simInput_hg.dPd_l_gg = 2*simInput_hg.dPd_l_gg;
simInput_hg.nWeek_gg = 2*simInput_hg.nWeek_gg;
result_hg = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_hg, fname_out_hg, vName );
%}
% <-- the difference is quite sensitive to "q_min"

%% Case 5 Ban is favoured when income inequality is high
% Not obvious
%{
income_thre = mean( myWeeklyIncome );
myWeeklyIncome_eq = zeros(1,nPop);
myLoss_mean_eq = zeros(1,nPop);
myLoss_std_eq = zeros(1,nPop);
wealthyIncome_sum = 0;
for iPopInd = 1:nPop
    iIncome = myWeeklyIncome(iPopInd);
    if iIncome < income_thre+0.01
        iIncome_ineq = iIncome * 2;
        myWeeklyIncome_eq(iPopInd) = iIncome_ineq;
        myLoss_mean_eq(iPopInd) = myLoss_mean(iPopInd) * 2; % If loss is not adjusted together, it takes too long for wealthy people to recover.
        myLoss_std_eq(iPopInd) = myLoss_std(iPopInd) * 2;
    else
        wealthyIncome_sum = wealthyIncome_sum + iIncome;
    end
end
wealthy_coeff = (sum(myWeeklyIncome) - sum(myWeeklyIncome_eq) ) / wealthyIncome_sum;
myWeeklyIncome_eq(~myWeeklyIncome_eq) = myWeeklyIncome(~myWeeklyIncome_eq) * wealthy_coeff;
myLoss_mean_eq(~myLoss_mean_eq) = myLoss_mean_eq(~myLoss_mean_eq) * wealthy_coeff;
myLoss_std_eq(~myLoss_std_eq) = myLoss_std_eq(~myLoss_std_eq) * wealthy_coeff;
myMaxLoss_eq = myWeeklyIncome_eq*20;

fname_out_eq = 'eq_income';
result_eq = gg.sampleRecSimul( nSample, myWeeklyIncome_eq, myLoss_mean_eq, myLoss_std_eq, myMaxLoss_eq, simInput, fname_out_eq, vName );
%}


%% Case 6 Hoarding
fname_out_hd = 'hoarding';
simInput_hd = simInput;
simInput_hd.donation = 0;
simInput_hd.hoarding = 1;
simInput_hd.nWeek_hd = simInput_hd.nWeek_gg;
result_hd = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_hd, fname_out_hd, vName );
% --> increases "Qb_lack"

%% Case 7 Donation
fname_out_dn = 'donation';
simInput_dn = simInput;
simInput_dn.hoarding = 1;
simInput_dn.nWeek_hd = simInput_dn.nWeek_gg;
simInput_dn.donation = 0.05;
result_dn = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_dn, fname_out_dn, vName );

%% Case 8 More bonding society
fname_out_bd = 'bond';
simInput_bd = simInput_dn;
simInput_bd.hoarding = 0.2;
result_bd = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_bd, fname_out_bd, vName );