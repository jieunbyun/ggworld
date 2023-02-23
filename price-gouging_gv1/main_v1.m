%{
Development in progress
%}

%{
18 Feb 22 - JB
*To be analysed: Supply price increase, price gouging, ban, harding, justice, uncertainty
*Who are the suppliers?: Let's quantify their profits.

Qs:
*Is "weeks_to_recover_dist" being used?
*How about instead of using "consumption_reduction" allocating survival first and then restoration, happiness?
*When deciding hoarding, do we need "isBan" in addition to checking supply lack?
*What is the meaning of aggregating DemSlope? - v 230219
%}


clear all; 
rng(1);

N = 1e3; % population
N = 5;

%
% Some parameters
%

%unaffected areas -- To be discussed in parametric study
%TODO: currently no explicit mechanism for rich people to recover quickly
%Just the variance is large.

dQd     = 5; % Parameter 1 - Increased quantity demand after disaster
dPd = 0.5; % Parameter 2 - Increased price after disaster 
SupSlope = 1; % Normalized
DemSlope = -1; % Normalized?
P = 1; % price level

%
% Predisaster Quantity demand and Living Cost
%

iq_min = 0.1; % Parameter - Min. living quantity 
alp_min = 0.8; % Parameter - Quantity needs increase per unit income 

%
% Income Distribution (per-week)
%

% I_avg = 0.2; % Parameter -  mean income
% I_min = iq_min; % min income
% I_std = 1*I_avg; % Parameter - income c.o.v.

%
% Price gouging 
%

% Price gouging ban
% Assuming equal share to meet basic living
dPc = 0.1; % Parameter - price increase cap


%
% Justice
%

% sympathy_level = 0.5; % Key Parameter -  ranges 0~1, cannot be zero
sympathy_level = 0;
% dQh = 0.3*(1-sympathy_level);% Parameter - reduced hoarding %TODO did I include this?
dQh = 0;
% dPpg = 0.5*(1-sympathy_level); % Parameter - price gouging
dPpg = 0;
donate_ratio = sympathy_level; % Parameter - donation of remaining weekly income

%TODO: people with additional income donate to the
%      community....... now income is not carried over...

%% Simulation of [Scenario A,B]
random_cov = 0.2; % Parameter 
%random_cov_Qd = 0.5; % Parameter 
weeks_to_recover= 10; % Parameter - when post-disaster selling ratio is 100%
dQd_basic = 0.50; % Temporary increase in basic living demand

%
% Generate distributions
%
dQd_basic_dist = truncate(makedist('Normal', dQd_basic, dQd_basic*random_cov), 0, inf); %This is increase due to increase in the basic living demand
%dQd_dist = truncate(makedist('Normal', dQd, dQd*random_cov_Qd), 0, inf); %This is increase due to repair action
dPd_dist = truncate(makedist('Normal', dPd, dPd*random_cov), 0, inf);
SupSlope_dist = truncate(makedist('Normal', SupSlope, SupSlope*random_cov), 0, inf);
iDemSlope_dist = truncate(makedist('Normal', N*DemSlope, abs(N*DemSlope)*random_cov), -inf, 0);
dPpg_dist = truncate(makedist('Normal', dPpg, dPpg*random_cov), 0, inf);
dQh_dist = truncate(makedist('Normal', dQh, dQh*random_cov), 0, inf);
% I_dist = truncate( makedist("Lognormal", log(I_avg^2/sqrt(I_std^2+I_avg^2)), sqrt(log(I_std^2/I_avg^2+1))), I_min, inf );
weeks_to_recover_dist = truncate(makedist('Normal', weeks_to_recover, 1), 0, inf);

nSample = 1e2;


nWeeks = 50; % simulaition time window

% placeholders
RecoveryWeeks = zeros(nSample,nWeeks);
HappynessDiscount = zeros(nSample,1);
RecoveryWeeks_ban = zeros(nSample,nWeeks);
HappynessDiscount_ban = zeros(nSample,1);

% iI = random(I_dist, 1, N); % individual income
% iI(iI<iq_min*P)=iq_min*P; % minimum wage    
R2D=load('R2D_data/R2Ddata.mat');


for ii = 1:nSample
    
    idx = randsample(length(R2D.myWeeklyIncome),N); % random permutation
    iI = R2D.myWeeklyIncome(idx)'/mean(R2D.myWeeklyIncome);% TODO: Do we need minimum wage: (230223) Reflected in R2D data
    
    idqd_samp = normrnd(R2D.myMeanRepCost(idx), R2D.myStdRepCost(idx))';
%     rv.idQd_samp = idqd_samp./R2D.myWeeklyIncome(idx)';
    rv.idQd_samp = idqd_samp./mean(R2D.myWeeklyIncome); % (230223) this seems to be a correct way of normalisation
    rv.idQd_samp(rv.idQd_samp<0)=0;    
%     rv.idQd_samp(rv.idQd_samp>25)=25;   % (230223) Do we need this? 
    
    %
    % gen samples of agents [1 x nPoP]
    %

    %rv.idQd_samp     = random(dQd_dist, 1,N); % This is factor multiplied by original quantity

    rv.iDemSlope_samp = random(iDemSlope_dist,1,N);    %TODO : random slope?
     %
    % gen samples of world [1 x 1]
    %
     
    rv.weeks_to_recover_samp     = random(weeks_to_recover_dist, 1); %TODO
    rv.dPd_samp = random(dPd_dist,1);
    rv.SupSlope_samp = random(SupSlope_dist,1);
    rv.dPpg_samp = random(dPpg_dist,1);
    rv.dQh_samp = random(dQh_dist, 1);
    rv.dQd_basic_samp = random(dQd_basic_dist, 1);
    
    %
    % case 1 Ban
    %
     
    isCaseBan= 1; figID=0;
    [idqd_hist_ban, happiness_discount_hist_ban] = gg.simulBan(figID, isCaseBan, nWeeks,iI, iq_min, alp_min, dPc, donate_ratio, rv);
    RecoveryWeeks_ban(ii,:) = [0 diff(sum(idqd_hist_ban'==0))];
    HappynessDiscount_ban(ii) = sum(happiness_discount_hist_ban(:));

    %
    % case 2 NoBan
    %
    
    isCaseBan= 0; figID=100;
    rv2=rv;
    %rv2.dQh_samp=0; TODO: do we need this?
    [idqd_hist, happiness_discount_hist] = gg.simulBan(figID, isCaseBan, nWeeks, iI, iq_min, alp_min, dPc,donate_ratio, rv2);
    RecoveryWeeks(ii,:) = [0 diff(sum(idqd_hist'==0))];
    HappynessDiscount(ii) = sum(happiness_discount_hist(:));
    
    rvSamples(ii,:) = [rv.weeks_to_recover_samp, rv.dPd_samp, rv.SupSlope_samp, rv.dPpg_samp, rv.dQh_samp, rv.dQd_basic_samp];
end


meanRecoveryWeek = mean(RecoveryWeeks*[1:nWeeks]'./sum(RecoveryWeeks')');
meanRecoveryWeek_ban = mean(RecoveryWeeks_ban*[1:nWeeks]'./sum(RecoveryWeeks_ban')');
meanSadness = mean(HappynessDiscount);
meanSadness_ban = mean(HappynessDiscount_ban);
