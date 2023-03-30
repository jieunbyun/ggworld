%{
Created: 30 March 2023

Apply test3 to R2D data
_sampling: Run sampling for situations of interest
%}

% clear all; 
rng(1);

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
% Normalised
simInput.dQd_b = 0.5; % Increased quantity demand after disaster - basic quantities: "_b" stands for basic living costs
simInput.dPd_b = 0.1; % Increased supply price after disaster
simInput.SupSlope_b = 1;

simInput.dPd_l = 0.1;
simInput.SupSlope_l = simInput.SupSlope_b*0.5; % assumed to be less sensitive.

simInput.pcap_b = 0.1; % Price cap for basic living. If less than "dPd_b", production decreases.
simInput.pcap_l = 0.1;

% Etc.
simInput.hoarding = 0;
simInput.donation = 0; 
%%%%%%%%%%%%%%%%%%%%%%

income_min = min(R2D.myWeeklyIncome); alp_min = 0.5; q_min = 0.8*min(R2D.myWeeklyIncome);
simInput.q_b_fun = @(incomes) min([q_min + alp_min * (incomes(:)') - income_min; 10*q_min*ones(1,length(incomes))], [], 1);

simInput.weeks_to_recover = 8; % Not anymore increase in basic quantity and supply price.
nSample = 1e3;

%% Case 1 Default
fname_out = 'default';
simInput.dPd_b_gg = 0.2; simInput.dPd_l_gg = 0.5; simInput.nWeek_gg = 10; % price-gouging rate
result_def = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput, fname_out );
% --> The difference of the number of recovery weeks increases with (1) the upper cap of loss and (2) SupSlope_l.

%% Case 2 When pcap is too stringent compared to dPd
fname_out_hp = 'high_dPd';
simInput_hp = simInput;
simInput_hp.dPd_l = 0.595; 
result_hp = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_hp, fname_out_hp );
% --> The number of recovery weeks with ban in place starts increasing when (pcap_l - dPd_l) / SupSlope_l < -0.98.

%% Case 3 Ban is not effective when there is not much loss
fname_out_ll = 'low_loss';
loss_coeff = 0.1;
myLoss_mean_ll = loss_coeff * myLoss_mean; myLoss_std_ll = loss_coeff * myLoss_std; myMaxLoss_ll = loss_coeff * myMaxLoss;
result_ll = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean_ll, myLoss_std_ll, myMaxLoss_ll, simInput, fname_out_ll );

%% Case 4 Ban is favoured when price gouging is high
fname_out_hg = 'high_goug';
simInput_hg = simInput;
simInput_hg.dPd_b_gg = 2*simInput_hg.dPd_b_gg;
simInput_hg.dPd_l_gg = 2*simInput_hg.dPd_l_gg;
simInput_hg.nWeek_gg = 2*simInput_hg.nWeek_gg;
result_hg = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_hg, fname_out_hg );
% <-- the difference is quite sensitive to "q_min"

%% Case 5 Ban is favoured when income inequality is high -- Not obvious
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
myLoss_mean_eq(~myLoss_mean_eq) = myLoss_sample1(~myLoss_mean_eq) * wealthy_coeff;
myLoss_std_eq(~myLoss_std_eq) = myLoss_std_eq(~myLoss_std_eq) * wealthy_coeff;
myMaxLoss_eq = myWeeklyIncome_eq*20;

fname_out_eq = 'eq_income';
result_eq = gg.sampleRecSimul( nSample, myWeeklyIncome_eq, myLoss_mean_eq, myLoss_std_eq, myMaxLoss_eq, simInput, fname_out_eq );


%% Case 6 Hoarding
fname_out_hd = 'hoarding';
simInput_hd = simInput;
simInput_hd.hoarding = 0.2;
result_hd = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_hd, fname_out_hd );
% --> increases "Qb_lack"

%% Case 7 Donation
fname_out_dn = 'donation';
simInput_dn = simInput;
simInput_dn.donation = 0.1;
result_dn = gg.sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput_dn, fname_out_dn );

