function result = simulation( SupSlope_b, SupSlope_l, dPd_b, dPd_l, dQd_b, weeks_to_recover, pops_income, pops_loss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, nWeek_hd, donation, dPd_b_gg, dPd_l_gg, nWeek_gg )

if nargin < 11
    pcap_b = inf; % no cap
end
if nargin < 12
    pcap_l = inf; % no cap
end
if nargin < 13
    hoarding = 0; % no hoarding considered
end
if nargin < 14
    donation = 0; % no donation considered
end
if nargin < 15
    dPd_b_gg = 0; % price-gouging not considered
end
if nargin < 16
    dPd_l_gg = 0; 
end
if nargin < 17
    nWeek_gg = 0;
end


%% Placeholders
nPop = length(pops_income);

loss_rem_hist = zeros(0,nPop); % Remaining loss 
pr_b_def_hist = zeros(0,nPop); % Monetary deficit for basic living
Q_b_def_hist = zeros(0,nPop); % (Normalised) Quantity deficit for basic living, incurred by insufficient income

% % Matrices below become non-zero when price cap is activated % %
Qb_lack_hist = zeros(0,1); % (Normalised) Quantity of supply lack for basic living
Prb_nat_hist = zeros(0,1); % (Normalised) Price increase if there had been no ban for basic living
Ql_lack_hist = zeros(0,1); % (Normalised) Quantity of supply lack for repair
Prl_nat_hist = zeros(0,1); % (Normalised) Price increase if there had been no ban for repair


%% Simulation begins
q_b_normal = q_b_fun(pops_income);

loss_rem = pops_loss;
iWeek = 0;
nWeek_max = 500;

while any(loss_rem > 0 ) && (iWeek < nWeek_max)
    iWeek = iWeek+1;

    iIncome_remain = pops_income;
    
    % % (1) basic living first
    dPt_b = max([0, dPd_b*(1-(iWeek-1)/weeks_to_recover)]);
    dQt_b = max([0, dQd_b*(1-(iWeek-1)/weeks_to_recover)]);
    Prd_b = SupSlope_b * (1+dQt_b -1) + dPt_b +1; % Increased percentage price after disasters    

    if Prd_b > (1+pcap_b)
        Prd_b_nat = Prd_b; 
        Prd_b = (1+pcap_b);
        if iWeek <= nWeek_hd
            dQt_b = dQt_b + hoarding;
        end

        dQt_b_sup = (pcap_b - dPd_b) / SupSlope_b; % Supply lack for basic living is not considered for price calculation (Not to double count effect of supply lack)
        Qb_lack = max([0, dQt_b-dQt_b_sup]); 

    else        

        if iWeek <= nWeek_gg % price-gouging
           Prd_b = min([Prd_b + dPd_b_gg*(1-(iWeek-1)/nWeek_gg), 1+pcap_b]); 
%            Prd_b = min([Prd_b + dPd_b_gg, 1+pcap_b]); 
        end

        Prd_b_nat = Prd_b;
        Qb_lack = 0;
    end

    prd_b_pop = Prd_b*q_b_normal*(1+dQt_b); 
    iIncome_remain = iIncome_remain - prd_b_pop;
    qb_dfc_inds = (iIncome_remain<0);
       
    iQb_dfc = zeros(1,nPop); % Normalised quantity of basic living deficit
    iQb_dfc(qb_dfc_inds) = abs(iIncome_remain(qb_dfc_inds) ./ prd_b_pop(qb_dfc_inds)); % This quantity reflects deficit 
    
    if Qb_lack > 0
        iQb_dfc_byIncomeLack = sum(iQb_dfc.*q_b_normal) / sum(q_b_normal); % Although income is assumed to be consumed (to not overestimate ban's effect), quantity deficit by supply lack is quantified (to not overlook the supply lack issue).
        Qb_lack = max([0, Qb_lack-iQb_dfc_byIncomeLack]); % Adjusted to consider those who cannot buy because of insufficient income
    end
    
    iprb_dfc = zeros(1,nPop); % Monetary value of basic living deficit
    iprb_dfc(qb_dfc_inds) = abs(iIncome_remain(qb_dfc_inds));
    iIncome_remain(qb_dfc_inds) = 0;
    
    % % (2) Repair cost
    dQd_l = sum(loss_rem)/tq_l;
    Prd_l = SupSlope_l * (1+dQd_l -1) + dPd_l +1; % Increased percentage price after disasters - repair
    
    if Prd_l > (1+pcap_l)
        
        Prd_l_nat = Prd_l; 
        Prd_l = 1+pcap_l;

        dQd_l_sup = max([-0.99, (pcap_l - dPd_l) / SupSlope_l]);
        Ql_lack = max([0, dQd_l-dQd_l_sup]); 
    else
        Prd_l_nat = Prd_l;
        dQd_l_sup = dQd_l;
        Ql_lack = 0;

        if iWeek < nWeek_gg % price-gouging
            Prd_l = min([Prd_l + dPd_l_gg, 1+pcap_l]); 
        end
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
        
        loss_rem(~iPopRecovered) = loss_rem(~iPopRecovered) - iDonateTotal / sum(~iPopRecovered) / Prd_l;
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
    loss_rem(loss_rem<1) = 0;

end


nWeekToRecover_pop = zeros(nPop,1);
for ii = 1:nPop
    iWeekToRecover = find( ~(loss_rem_hist(:,ii)>0), 1 ) - 1;
    if ~isempty( iWeekToRecover )
        nWeekToRecover_pop(ii) = iWeekToRecover;
    else
        nWeekToRecover_pop(ii) = size(loss_rem_hist,1);
    end
end


result.loss_rem_hist = loss_rem_hist;
result.pr_b_def_hist = pr_b_def_hist;
result.Q_b_def_hist = Q_b_def_hist;
result.Qb_lack_hist = Qb_lack_hist;
result.Prb_nat_hist = Prb_nat_hist;
result.Ql_lack_hist = Ql_lack_hist;
result.Prl_nat_hist = Prl_nat_hist;
result.nWeekToRecover_pop = nWeekToRecover_pop;

if all(~loss_rem)
    fprintf( 'Weeks for all to recover: %4d\n', max(nWeekToRecover_pop) )
else
    disp( 'There are people who did not recover fully.' )
end