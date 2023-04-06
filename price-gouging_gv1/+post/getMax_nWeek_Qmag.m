function [nWeek_max, Qmag_max] = getMax_nWeek_Qmag( dataNames )

nWeek_max = 0;
Qmag_max = 0;
nData = length(dataNames);
for iDataInd = 1:nData
    data = load( strcat( 'outputs\', dataNames(iDataInd), '.mat' ), "result" );

    Qb_def_mag_ban = data.result.Q_supply_lack_mag_Qb;
    Qb_def_nWeek_ban = data.result.Q_supply_lack_nWeek_Qb;

    Qb_def_nWeek_noban = data.result.Qb_def_nWeek_noban;
    Qb_def_mag_noban = data.result.Qb_def_mag_noban;

    nWeek_max = max([nWeek_max; Qb_def_nWeek_ban(:); Qb_def_nWeek_noban(:)]);
    Qmag_max = max( [Qmag_max; Qb_def_mag_ban(:); Qb_def_mag_noban(:)] );
end

