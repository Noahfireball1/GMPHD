function customPlot(gmphd,timeStep)
%CUSTOMPLOT plots scatter of truth,measurements, and estimated states of each object

g = groot;
if isempty(g.Children)

    figure;
    set(gca,'FontSize',12)
    set(gcf,"Units","normalized")
    set(gcf,"Position",[0.25 0.25 0.25 0.5])
    hold on
    xlim([-1000 1000])
    ylim([-1000 1000])

    xlabel('X-Position [m]')
    ylabel('Y-Position [m]')
    title(sprintf('GM-PHD - Scenario: %s',gmphd.Initialization.scenario))

end

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
    scatter(estimates(1,:),estimates(3,:),weights*50,'filled','MarkerFaceColor','#00470c','MarkerEdgeColor','#00470c');
end

legend('Truth','Measurements','Estimates')
pause(0.1)
end