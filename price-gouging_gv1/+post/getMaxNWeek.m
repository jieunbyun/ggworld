function nWeek_max = getMaxNWeek( dataNames )

nWeek_max = 0;
nData = length(dataNames);
for iDataInd = 1:nData
    data = load( strcat( 'outputs\', dataNames(iDataInd), '.mat' ), "result" );

    nWeekRec_ban = data.result.nWeekRec_ban;
    nWeekRec_noban = data.result.nWeekRec_noban;

    iNWeek_max = max([nWeekRec_ban(:); nWeekRec_noban(:)]);
    nWeek_max = max([nWeek_max, iNWeek_max]);
end