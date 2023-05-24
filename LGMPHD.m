function [truth,observations,estimates] = LGMPHD(scenario)

%% Load in specified scenario
switch scenario
    case 'simple'
        parameters = scenarios.simple();
        numTimestep = parameters.num_timestep;
        truth = generate.simple(parameters.motion_model.F,numTimestep);

    case 'OSPA'
        parameters = scenarios.OSPA();
        numTimestep = parameters.num_timestep;
        truth = generate.OSPA(parameters.motion_model.F,numTimestep);

    case 'random'
        parameters = scenarios.random();
        numTimestep = parameters.num_timestep;
        truth = generate.random(parameters.motion_model.F,numTimestep);
    otherwise
        error('Incorrect scenario specified!')
end



%Generate measurements
measurements = generate.measurements(parameters.motion_model,truth,parameters.filter_parameters);

motion_model = parameters.motion_model;
filter_parameters = parameters.filter_parameters;
birth_parameters = parameters.birth_parameters;
spawn_parameters = parameters.spawn_parameters;
state_variables = parameters.initial_state_variables;

%% Start Filter
for timestep = 1:numTimestep

    % Predict Step
    predicted_state_variables = phd.predict(motion_model,filter_parameters.P_survival,birth_parameters,spawn_parameters,state_variables);
    filter_numbers.num_gauss_predict = length(predicted_state_variables.weight);

    % Observation
    observations{timestep} = measurements.state{timestep};

    % Update Step
    updated_state_variables = phd.update(motion_model,filter_parameters,observations{timestep},predicted_state_variables);
    filter_numbers.num_gauss_start= numel(updated_state_variables.weight);

    % Prune, Merge, and Cap
    [filtered_state_variables, filter_number_output] = phd.filter(filter_parameters, timestep, updated_state_variables);
    filter_numbers.num_gauss_prune = filter_number_output.num_gauss_prune;
    filter_numbers.num_gauss_merge = filter_number_output.num_gauss_merge;
    filter_numbers.num_gauss_cap = filter_number_output.num_gauss_cap;

    % State Extraction

    %Prepare for next timestep
    state_variables = filtered_state_variables;


end


end