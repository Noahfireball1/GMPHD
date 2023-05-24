%% Formatting
clc
clear
close all
format shortg

%% Setting Case
rng('default')
scenario = 'simple'; % 'simple' or 'OSPA' or 'random'

%% Running LGM-PHD
[truth,measurements,estimates] = LGMPHD(scenario);

%% Plotting

filterFig = figure('Units','normalized','WindowStyle','docked');
hold on
[labelColor, labelSymbol] = other.get_list_color_and_symbol;
for timestep = 1:size(truth.state,1)

    for truthSizeIdx = 1:size(truth.state{timestep},2)
        scatter(truth.state{timestep}(1,truthSizeIdx),truth.state{timestep}(3,truthSizeIdx),70,'xk')
    end

    for measSizeIdx = 1:size(measurements{timestep},2)
        scatter(measurements{timestep}(1,measSizeIdx),measurements{timestep}(2,measSizeIdx),'*r')
    end

    % Color coding estimates based on their estimated label
    if ~isempty(estimates.state_variables.state{timestep})
        labels(timestep,1:numel(estimates.state_variables.state{timestep}(1,:))) = estimates.state_variables.label{timestep};
        for estiSizeIdx = 1:size(estimates.state_variables.state{timestep},2)
            scatter(estimates.state_variables.state{timestep}(1,estiSizeIdx),estimates.state_variables.state{timestep}(2,estiSizeIdx),...
                50,'filled','MarkerFaceColor',labelColor(labels(timestep,estiSizeIdx),:),'Marker',labelSymbol(labels(timestep,estiSizeIdx)))
        end
    end
end


