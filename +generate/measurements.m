% measurements = generate_measurements(motion_model,truth_data,filter)
% Measurements for given motion model, truth data, filter parameters, and
% clutter region
%
% Inputs:
%   motion_model - length of one time step for motion model
%       model.z_dim - number of measurements
%       model.R - Measurement uncertainity - size [nz,nz]
%       model.H - observation matrix  - size [nz,nx]
%   truth_data - data structure of truth data
%       truth_data.num_timestep - total number of timesteps
%       truth_data.num_targets - number of targets at individual timesteps
%       truth_data.state - state of targets at individual timesteps
%   filter - filter parameters
%       filter.P_detection - probability of detection
%       filter.lambda - false alarm number
%       filter.clutter_region - [min, max] for each measurement dimension that
%       emcompasses the allowed clutter region/state
%
% Outputs:
%   measurements - data structure of measurement data
%       measurements.num_timestep - total number of timesteps
%       measurements.state - all measurements (truth and clutter)
%       measurements.state_no_clutter - just measurements relating to the truth data
%       measurements.state_clutter - just measurements relating to clutter
%       measurements.num_measurements - number of total measurements for each timestep
%
% Needed functions: poissrnd
%
% Written by Deanna Phillips - 10/25/2022
% Modified by Deanna Phillips - 03/03/2023

function measurements = measurements(motion_model,truth_data,filter)
%% Pre-Allocating
measurements.num_timesteps = truth_data.num_timestep; % Length of data/number of scans
measurements.state_no_clutter = cell(truth_data.num_timestep,1); % Measurement states without clutter
measurements.state_clutter = cell(truth_data.num_timestep,1); % Measurement states with clutter
measurements.state = cell(truth_data.num_timestep,1); % All measurement states
measurements.num_measurements = zeros(truth_data.num_timestep,1); % Number of measurements

%% Generating Measurements and Clutter
for kk = 1:truth_data.num_timestep

    %% Measurement states
    if truth_data.num_targets(kk) > 0
        % There is a chance that an object isn't detected
        idx = find(rand(truth_data.num_targets(kk),1) <= filter.P_detection);

        %Number of just targets detected
        num_targets=size(truth_data.state{kk,1}(:,idx),2);

        %Randomize noise
        R = sqrt(motion_model.R)*randn(motion_model.z_dim,num_targets);

        % Measurement model (y = Hx + R)
        measurements.state_no_clutter{kk} = motion_model.H*truth_data.state{kk,1}(:,idx) + R;
    end

    %% Clutter states
    % Number of clutter points
    num_false_alarm = poissrnd(filter.lambda); % every timestep, different number of false alarm detections

    %Total clutter region size
    clutter_size=filter.clutter_region*[ -1; 1 ];

    %Clutter region minimum value
    clutter_region_min_value=repmat(filter.clutter_region(:,1),[1 num_false_alarm]);

    %Gaussian value for clutter
    clutter_gaussian_value=diag(clutter_size)*rand(motion_model.z_dim,num_false_alarm);

    %Clutter states
    measurements.state_clutter{kk} = clutter_region_min_value + clutter_gaussian_value;

    % Measurements are the combination of clutter and modelled measurements
    measurements.state{kk} = [measurements.state_no_clutter{kk}  measurements.state_clutter{kk}];

    % Number of measurements for timestep
    measurements.num_measurements(kk)=size(measurements.state{kk},2);
end

end