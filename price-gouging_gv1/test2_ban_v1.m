%{
Development in progress
%}

%{
Created: 4 Mar 2023 - JB
Last udpate: 5 Mar 2023 - JB
Add ban to test1 
%}

% clear all; 
rng(1);

load("test_data/evalPQ.mat")
% load("test_data/evalPQ_highLoss.mat")
% load("test_data/evalPQ_highDQ.mat")
% load("test_data/evalPQ_highTql.mat")
% load("test_data/evalPQ_highDPdb.mat")
% load("test_data/evalPQ_highDPdl.mat") % Does not run: sigular point
% load("test_data/evalPQ_highSupSlopel.mat")

%% Evaluation of price
% For record
loss_rem_hist = zeros(0,nPop); % Remaining loss 
pr_b_def_hist = zeros(0,nPop); % Monetary deficit for basic living
Q_b_def_hist = zeros(0,nPop); % (Normalised) Quantity deficit for basic living
% % Specific to price cap % %
Qb_lack_hist = zeros(0,1); % (Normalised) Quantity of supply lack for basic living
Prb_nat_hist = zeros(0,1); % (Normalised) Price increase if there had been no ban for basic living
Ql_lack_hist = zeros(0,1); % (Normalised) Quantity of supply lack for repair
Prl_nat_hist = zeros(0,1); % (Normalised) Price increase if there had been no ban for repair


q = q_min + alp_min * (myWeeklyIncome - q_min); % individual demands
loss_rem = myLoss;
iWeek = 0;
pcap_b = 0.2; % Price cap for basic living. If less than "dPd_b", production decreases.
pcap_l = 0.2; % Price cap for repair.
hoarding = 0.2; % --> increases "Qb_lack"
donation = 0.2; 
while any(loss_rem > 0 )
    iWeek = iWeek+1;

    iIncome_remain = myWeeklyIncome;
    
    % % (1) basic living first
    dPt_b = max([0, dPd_b*(1-(iWeek-1)/weeks_to_recover)]);
    dQt_b = max([0, dQd_b*(1-(iWeek-1)/weeks_to_recover)]);
    Prd_b = SupSlope_b * (1+dQt_b -1) + dPt_b +1; % Increased percentage price after disasters

    if Prd_b > (1+pcap_b)
        Prd_b_nat = Prd_b; 
        Prd_b = (1+pcap_b);
        dQt_b = dQt_b + hoarding;

        dQt_b_sup = (pcap_b - dPd_b) / SupSlope_b;
        Qb_lack = max([0, dQt_b-dQt_b_sup]); 
    else        
        Prd_b_nat = Prd_b;
        dQt_b_sup = dQt_b;
        Qb_lack = 0;
    end

   
%     prd_b_pop = Prd_b*q*(1+dQt_b_sup); % actual prices for basic living for each population: When dQt_b_sup < dQt_b, proportional distribution among populations is assumed (which is not far from the alleged random distribution).
    prd_b_pop = Prd_b*q*(1+dQt_b); % Not to double count effect of supply lack
    iIncome_remain = iIncome_remain - prd_b_pop;
    qb_dfc_inds = (iIncome_remain<0);
    
    iQb_dfc = zeros(1,nPop); % Normalised quantity of basic living deficit
    iQb_dfc(qb_dfc_inds) = abs(iIncome_remain(qb_dfc_inds) ./ prd_b_pop(qb_dfc_inds));
    
    iprb_dfc = zeros(1,nPop); % Monetary value of basic living deficit
    iprb_dfc(qb_dfc_inds) = abs(iIncome_remain(qb_dfc_inds));
    iIncome_remain(qb_dfc_inds) = 0;
    
    % % (2) Repair cost
    dQd_l = sum(loss_rem)/tq_l;
    Prd_l = SupSlope_l * (1+dQd_l -1) + dPd_l +1; % Increased percentage price after disasters - repair
    
    if Prd_l > (1+pcap_l)
        
        Prd_l_nat = Prd_l; 
        Prd_l = 1+pcap_l;

        dQd_l_sup = (pcap_l - dPd_l) / SupSlope_l;
        Ql_lack = max([0, dQd_l-dQd_l_sup]); 
    else
        Prd_l_nat = Prd_l;
        dQd_l_sup = dQd_l;
        Ql_lack = 0;
    end

    ipr_l = loss_rem*Prd_l;
    if Ql_lack > 0
        ipr_l = ipr_l * (1+dQd_l_sup) / dQd_l;
        ipr_l(ipr_l<0) = 0;
    end
    ircv_l = min([iIncome_remain; ipr_l]); % recovered loss
    iRcv_l = ircv_l / Prd_l; % recovered loss - normalised
    loss_rem = max( [loss_rem - iRcv_l; zeros(size(loss_rem))]);

    if donation > 0
        iPopRecovered = ~(loss_rem > 0);
        iNetIncome = iIncome_remain(iPopRecovered);
        iNetIncome(iNetIncome<0) = 0;
        iDonateTotal = donation * sum( iNetIncome );
        
        loss_rem(~iPopRecovered) = loss_rem(~iPopRecovered) - iDonateTotal / sum(~iPopRecovered);
        loss_rem = max( [loss_rem; zeros(size(loss_rem))] );
    end
    
    % % Record
    loss_rem_hist = [loss_rem_hist; loss_rem];
    pr_b_def_hist = [pr_b_def_hist; iprb_dfc];
    Q_b_def_hist = [Q_b_def_hist; iQb_dfc];
    Qb_lack_hist = [Qb_lack_hist; Qb_lack];
    Prb_nat_hist = [Prb_nat_hist; Prd_b_nat];
    Ql_lack_hist = [Ql_lack_hist; Ql_lack];
    Prl_nat_hist = [Prl_nat_hist; Prd_l_nat];
end

nWeekToRecover_pop = zeros(nPop,1);
for ii = 1:nPop
    nWeekToRecover_pop(ii) = find( ~(loss_rem_hist(:,ii)>0), 1 ) - 1;
end

nBin = 5;
figure(1);
histogram(nWeekToRecover_pop,nBin)
figure(2);
scatter( myWeeklyIncome, nWeekToRecover_pop, 'filled' )
grid on
disp( "Weeks for all to recover: "+num2str(max(nWeekToRecover_pop)) )
