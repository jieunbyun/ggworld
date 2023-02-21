%{
Development in progress
%}

%{
21 Feb 22 - JB
*To be analysed: Supply price increase, price gouging, ban, harding, justice, uncertainty
*Who are the suppliers?: Let's quantify their profits.

Qs:
*Is "weeks_to_recover_dist" being used?
*How about instead of using "consumption_reduction" allocating survival first and then restoration, happiness?
*When deciding hoarding, do we need "isBan" in addition to checking supply lack?
*What is the meaning of aggregating DemSlope? - v 230219

v2: only ban vs. no-ban
%}


clear all; 
rng(1);

% N = 1e3; % population
N = 5;

%
% Some parameters
%

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
% Price gouging 
%
pg_r = 0.5; % Parameter - price gouging takes place until "pg_r" recovery takes place: v2 update

% Price gouging ban
% Assuming equal share to meet basic living
dPc = 0.1; % Parameter - price increase cap


%% Simulation of [Scenario A,B]
random_cov = 0.2; % Parameter 

%
% Generate distributions
%
dPd_dist = truncate(makedist('Normal', dPd, dPd*random_cov), 0, inf);
SupSlope_dist = truncate(makedist('Normal', SupSlope, SupSlope*random_cov), 0, inf);
iDemSlope_dist = truncate(makedist('Normal', N*DemSlope, abs(N*DemSlope)*random_cov), -inf, 0);

nSample = 1e2;

nWeeks = 50; % simulation time window

% placeholders
RecoveryWeeks = zeros(nSample,nWeeks);
HappynessDiscount = zeros(nSample,1);
RecoveryWeeks_ban = zeros(nSample,nWeeks);
HappynessDiscount_ban = zeros(nSample,1);


R2D=load('R2D_data/R2Ddata.mat');


for ii = 1:nSample
    
    idx = randsample(length(R2D.myWeeklyIncome),N); % random permuntation
    iI = R2D.myWeeklyIncome(idx)'/mean(R2D.myWeeklyIncome);% TODO: Do we need minimum wage   
    
    idqd_samp = normrnd(R2D.myMeanRepCost(idx), R2D.myStdRepCost(idx))';
    rv.idQd_samp = idqd_samp/mean(R2D.myWeeklyIncome);
    rv.idQd_samp(rv.idQd_samp<0)=0;    
%     rv.idQd_samp(rv.idQd_samp>25)=25;    
    
    rv.iDemSlope_samp = random(iDemSlope_dist,1,N); 
    rv.dPd_samp = random(dPd_dist,1);
    rv.SupSlope_samp = random(SupSlope_dist,1);

    
    %
    % case 1 Ban
    %
     
    isCaseBan= 1; figID=0;
    [idqd_hist_ban, happiness_discount_hist_ban] = gg.simulBan_v2(figID, isCaseBan, nWeeks,iI, iq_min, alp_min, dPc, pg_r, rv);
    RecoveryWeeks_ban(ii,:) = [0 diff(sum(idqd_hist_ban'==0))];
    HappynessDiscount_ban(ii) = sum(happiness_discount_hist_ban(:));

    %
    % case 2 NoBan
    %
    
    isCaseBan= 0; figID=100;
    rv2=rv;
    %rv2.dQh_samp=0; TODO: do we need this?
    [idqd_hist, happiness_discount_hist] = gg.simulBan_v2(figID, isCaseBan, nWeeks, iI, iq_min, alp_min, dPc,donate_ratio, pg_r, rv2);
    RecoveryWeeks(ii,:) = [0 diff(sum(idqd_hist'==0))];
    HappynessDiscount(ii) = sum(happiness_discount_hist(:));
    
    rvSamples(ii,:) = [rv.weeks_to_recover_samp, rv.dPd_samp, rv.SupSlope_samp, rv.dPpg_samp, rv.dQh_samp, rv.dQd_basic_samp];
end


meanRecoveryWeek = mean(RecoveryWeeks*[1:nWeeks]'./sum(RecoveryWeeks')');
meanRecoveryWeek_ban = mean(RecoveryWeeks_ban*[1:nWeeks]'./sum(RecoveryWeeks_ban')');
meanSadness = mean(HappynessDiscount);
meanSadness_ban = mean(HappynessDiscount_ban);
