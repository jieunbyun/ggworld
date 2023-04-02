function result = sampleRecSimul( nSample, myWeeklyIncome, myLoss_mean, myLoss_std, myMaxLoss, simInput, fname_out, vName )

% Unpack simulation inputs
SupSlope_b = simInput.SupSlope_b;  SupSlope_l = simInput.SupSlope_l;
dPd_b = simInput.dPd_b;  dPd_l = simInput.dPd_l;  dQd_b = simInput.dQd_b;
q_b_fun = simInput.q_b_fun;  tq_l = simInput.tq_l; weeks_to_recover = simInput.weeks_to_recover;
if ~isfield( simInput, 'pcap_b' ); pcap_b = inf; else; pcap_b = simInput.pcap_b; end
if ~isfield( simInput, 'pcap_l' ); pcap_l = inf; else; pcap_l = simInput.pcap_l; end
if ~isfield( simInput, 'hoarding' ); hoarding = 0; else; hoarding = simInput.hoarding; end
if ~isfield( simInput, 'donation' ); donation = 0; else;  donation = simInput.donation; end
if ~isfield( simInput, 'dPd_b_gg' ); dPd_b_gg = 0; else; dPd_b_gg = simInput.dPd_b_gg; end
if ~isfield( simInput, 'dPd_l_gg' ); dPd_l_gg = 0; else; dPd_l_gg = simInput.dPd_l_gg; end
if ~isfield( simInput, 'nWeek_gg' ); nWeek_gg = 0; else; nWeek_gg = simInput.nWeek_gg; end

if ~isfield( simInput, 'dQd_b_cov' )
    dQd_b_cov = 0;
else
    dQd_b_cov = simInput.dQd_b_cov;
    dQd_b_dist = makedist('Normal', dQd_b, dQd_b*dQd_b_cov);
    dQd_b_dist = truncate( dQd_b_dist, 0, inf );
end
if ~isfield( simInput, 'dPd_b_cov' )
    dPd_b_cov = 0;
else
    dPd_b_cov = simInput.dPd_b_cov;
    dPd_b_dist = makedist('Normal', dPd_b, dPd_b*dPd_b_cov);
    dPd_b_dist = truncate( dPd_b_dist, 0, inf );
end
if ~isfield( simInput, 'SupSlope_b_cov' )
    SupSlope_b_cov = 0;
else
    SupSlope_b_cov = simInput.SupSlope_b_cov;
    SupSlope_b_dist = makedist( 'Normal', SupSlope_b, SupSlope_b*SupSlope_b_cov );
    SupSlope_b_dist = truncate( SupSlope_b_dist, 0, inf );
end
if ~isfield( simInput, 'dPd_l_cov' )
    dPd_l_cov = 0;
else
    dPd_l_cov = simInput.dPd_l_cov;
    dPd_l_dist = makedist( 'Normal', dPd_l, dPd_l*dPd_l_cov );
    dPd_l_dist = truncate( dPd_l_dist, 0, inf );
end
if ~isfield( simInput, 'SupSlope_l_cov' )
    SupSlope_l_cov = 0;
else
    SupSlope_l_cov = simInput.SupSlope_l_cov;
    SupSlope_l_dist = makedist('Normal', SupSlope_l, SupSlope_l*SupSlope_l_cov);
    SupSlope_l_dist = truncate(SupSlope_l_dist, 0, inf);
end

if nargin < 8
    vName = '';
end


% Init
nPop = length(myWeeklyIncome);

loss_pop = zeros(nSample,nPop);
nWeekRec_ban = zeros(nSample,nPop);
nWeekRec_noban = zeros(nSample,nPop);
Qb_def_mag_ban = zeros(nSample, nPop); % magnitude (normalised)
Qb_def_mag_noban = zeros(nSample, nPop);
Qb_def_nWeek_ban = zeros(nSample, nPop); % time (number of weeks)
Qb_def_nWeek_noban = zeros(nSample, nPop);
Q_supply_lack_mag_Qb = zeros(nSample,1); % Lack due to supply lack so applies to ban only.
Q_supply_lack_mag_Ql = zeros(nSample,1);
Q_supply_lack_nWeek_Qb = zeros(nSample,1); % Lack due to supply lack so applies to ban only.
Q_supply_lack_nWeek_Ql = zeros(nSample,1);

% Sampling
for iSampInd = 1:nSample
    disp( ['[' fname_out ']' 'Sample ' num2str(iSampInd) ' ..'] )
    rng(iSampInd) % To retreive sampling results
    iLoss = gg.sampleLoss( myLoss_mean, myLoss_std, myMaxLoss ); 

    if ~dQd_b_cov; idQd_b = dQd_b; else; idQd_b = random( dQd_b_dist, 1 ); end
    if ~SupSlope_b_cov; iSupSlope_b = SupSlope_b; else; iSupSlope_b = random( SupSlope_b_dist, 1 ); end
    if ~SupSlope_l_cov; iSupSlope_l = SupSlope_l; else; iSupSlope_l = random( SupSlope_l_dist, 1 ); end
    if ~dPd_b_cov; idPd_b = dPd_b; else; idPd_b = random(dPd_b_dist,1); end
    if ~dPd_l_cov; idPd_l = dPd_l; else; idPd_l = random(dPd_l_dist, 1); end

    % Simulation
    iResult_ban = gg.simulation( iSupSlope_b, iSupSlope_l, idPd_b, idPd_l, idQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, pcap_b, pcap_l, hoarding, donation, dPd_b_gg, dPd_l_gg, nWeek_gg );
    iResult_noban = gg.simulation( iSupSlope_b, iSupSlope_l, idPd_b, idPd_l, idQd_b, weeks_to_recover, myWeeklyIncome, iLoss, q_b_fun, tq_l, inf, inf, 0, 0, dPd_b_gg, dPd_l_gg, nWeek_gg );

    % Results summary
    loss_pop(iSampInd,:) = iLoss;

    nWeekRec_ban(iSampInd,:) = iResult_ban.nWeekToRecover_pop;
    nWeekRec_noban(iSampInd,:) = iResult_noban.nWeekToRecover_pop;

    Qb_def_mag_ban(iSampInd,:) = sum(iResult_ban.Q_b_def_hist,1);
    Qb_def_mag_noban(iSampInd,:) = sum(iResult_noban.Q_b_def_hist,1);

    Qb_def_nWeek_ban(iSampInd,:) = gg.getLastNonZeroIndices( iResult_ban.Q_b_def_hist, 1 );
    Qb_def_nWeek_noban(iSampInd,:) = gg.getLastNonZeroIndices( iResult_noban.Q_b_def_hist, 1 );

    Q_supply_lack_mag_Qb(iSampInd) = sum( iResult_ban.Qb_lack_hist );
    Q_supply_lack_mag_Ql(iSampInd) = sum( iResult_ban.Ql_lack_hist );

    Q_supply_lack_nWeek_Qb(iSampInd) = find( iResult_ban.Qb_lack_hist > 0, 1, 'last' );
    Q_supply_lack_nWeek_Ql(iSampInd) = find( iResult_ban.Ql_lack_hist > 0, 1, 'last' );

    if ~rem( iSampInd, round(nSample/10) )

        result.loss_pop = loss_pop(1:iSampInd,:);
        result.nWeekRec_ban = nWeekRec_ban(1:iSampInd,:);
        result.nWeekRec_noban = nWeekRec_noban(1:iSampInd,:);
        result.Qb_def_mag_ban = Qb_def_mag_ban(1:iSampInd,:); % magnitude (normalised)
        result.Qb_def_mag_noban = Qb_def_mag_noban(1:iSampInd,:);
        result.Qb_def_nWeek_ban = Qb_def_nWeek_ban(1:iSampInd,:); % time (number of weeks)
        result.Qb_def_nWeek_noban = Qb_def_nWeek_noban(1:iSampInd,:);
        result.Q_supply_lack_mag_Qb = Q_supply_lack_mag_Qb(1:iSampInd); % Lack due to supply lack so applies to ban only.
        result.Q_supply_lack_mag_Ql = Q_supply_lack_mag_Ql(1:iSampInd);
        result.Q_supply_lack_nWeek_Qb = Q_supply_lack_nWeek_Qb(1:iSampInd); % Lack due to supply lack so applies to ban only.
        result.Q_supply_lack_nWeek_Ql = Q_supply_lack_nWeek_Ql(1:iSampInd);
        
        save( strcat( 'outputs/', fname_out, vName, '.mat' ), 'result', 'nSample', 'myWeeklyIncome', 'myLoss_mean', 'myLoss_std', 'myMaxLoss', 'simInput', 'fname_out', 'vName' )
    end

end


% Save data
result.loss_pop = loss_pop;
result.nWeekRec_ban = nWeekRec_ban;
result.nWeekRec_noban = nWeekRec_noban;
result.Qb_def_mag_ban = Qb_def_mag_ban; % magnitude (normalised)
result.Qb_def_mag_noban = Qb_def_mag_noban;
result.Qb_def_nWeek_ban = Qb_def_nWeek_ban; % time (number of weeks)
result.Qb_def_nWeek_noban = Qb_def_nWeek_noban;
result.Q_supply_lack_mag_Qb = Q_supply_lack_mag_Qb; % Lack due to supply lack so applies to ban only.
result.Q_supply_lack_mag_Ql = Q_supply_lack_mag_Ql;
result.Q_supply_lack_nWeek_Qb = Q_supply_lack_nWeek_Qb; % Lack due to supply lack so applies to ban only.
result.Q_supply_lack_nWeek_Ql = Q_supply_lack_nWeek_Ql;

save( strcat( 'outputs/', fname_out, vName, '.mat' ), 'result', 'nSample', 'myWeeklyIncome', 'myLoss_mean', 'myLoss_std', 'myMaxLoss', 'simInput', 'fname_out', 'vName' )