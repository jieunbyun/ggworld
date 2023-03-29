%{
Created: 16 March 2023
Last update: 16 March 2023

Simulate parameters for toy example
%}

% clear all; 
rng(1);

%% Data

%%%% Population %%%%
nPop = 5;
myWeeklyIncome = [1 2 3 4 5];
myLoss = myWeeklyIncome * 10;
myLoss([2,4]) = 0; % there are some unaffected people.
%%%%%%%%%%%%%%%%%%%%

%%% When things are peaceful %%%
tq_l = sum(myLoss)*0.2; % total quantity in normality: "_l" stands for loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Model parameters %%%
% Normalised
dQd_b = 0.5; % Increased quantity demand after disaster - basic quantities: "_b" stands for basic living costs
dPd_b = 0.2; % Increased supply price after disaster
SupSlope_b = 1; 

dPd_l = 0.2;
SupSlope_l = SupSlope_b*0.1; % assumed to be less sensitive.

pcap_b = 0.2; % Price cap for basic living. If less than "dPd_b", production decreases.
pcap_l = 0.2;

% Etc.
hoarding = 0;
donation = 0; 
%%%%%%%%%%%%%%%%%%%%%%

income_min = 1; alp_min = 0.4; q_min = 0.6;
q_b_fun = @(incomes) q_min + alp_min * (incomes - income_min);

weeks_to_recover = 8; % Not anymore increase in basic quantity and supply price.


%% Supply restoration vs. living restoration
% Default parameters
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, inf, inf, hoarding, donation );

% Ban is not favoured when pcap is too stringent compared to dPd
pcap_l_less = 0.11;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, pcap_b, pcap_l_less, hoarding, donation );

% Ban is not effective when there is not much loss
myLoss_less = 0.1 * myLoss;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_less, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss_less, q_b_fun, tq_l, inf, inf, hoarding, donation );

% Ban is favoured when price gouging is high
dPd_b_gg = 0.5; dPd_l_gg = 0.5; nWeek_gg = 30; % price-gouging rate 
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, inf, inf, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );
% <-- the difference is quite sensitive to "q_min"

% Ban is favoured when income inequality is high
myWeeklyIncome_ineq = myWeeklyIncome; myWeeklyIncome_ineq(2:end) = 2*myWeeklyIncome(2:end);
myLoss_ineq = myLoss; myLoss_ineq(2:end) = 2*myLoss(2:end); 
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome_ineq, myLoss_ineq, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome_ineq, myLoss_ineq, q_b_fun, tq_l, inf, inf, hoarding, donation );


%% Hoarding
hoarding = 0.2;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
result_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, inf, inf, hoarding, donation );
% --> increases "Qb_lack"


%% Donation
donation = 0.2;
result_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, myLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
% --> Quickens recovery


%% Probabilistic analysis
nSample = 1e4;
nWeekRec_ban = zeros(nSample,nPop);
nWeekRec_noban = zeros(nSample,nPop);
myLoss_mean = myWeeklyIncome * 5;
for iSampInd = 1:nSample
    iLoss = randn(1,nPop) .* myLoss_mean + myLoss_mean;
    iLoss(iLoss<0) = 0;

    iResult_ban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation );
    iResult_noban = gg.simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, inf, inf, hoarding, donation );

    nWeekRec_ban(iSampInd,:) = iResult_ban.nWeekToRecover_pop;
    nWeekRec_noban(iSampInd,:) = iResult_noban.nWeekToRecover_pop;

end

nWeekRec_ban_avg = zeros(1,nPop); nWeekRec_noban_avg = zeros(1,nPop);
for iPopInd = 1:nPop
    iNWeekRec_ban = nWeekRec_ban(:,iPopInd);
    nWeekRec_ban_avg(iPopInd) = mean(iNWeekRec_ban(iNWeekRec_ban>0));

    iNWeekRec_noban = nWeekRec_noban(:,iPopInd);
    nWeekRec_noban_avg(iPopInd) = mean(iNWeekRec_noban(iNWeekRec_noban>0));
end
iPopInd = 5;
figure;
hist( [nWeekRec_ban(:,iPopInd), nWeekRec_noban(:,iPopInd)] )
grid on
% --> Ban controls worst scenarios (for all income levels).

% save outputs/test3_param_study.mat
