function customPlot(gmphd,timeStep)

%% Setting Namespaces
truth = gmphd.Initialization.state{timeStep};
numTargets = gmphd.Initialization.numTargets(timeStep);

measurements = gmphd.Observations.measurements;

estimates = gmphd.Extraction.extractedStates;
weights = gmphd.Extraction.extractedWeights;
numTracks = size(estimates,2);

% Truth
scatter(truth(1,:),truth(3,:),'*k');

% Measurements
scatter(measurements(1,:),measurements(2,:),'*r');

% Estimates
if ~isempty(estimates)
    scatter(estimates(1,:),estimates(3,:),weights*100,'blue','filled');
end

pause(0.1)
end