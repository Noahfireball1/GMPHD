% truth = generate_truth_simple(motion_model_F,num_timestep)
% Generate truth data for the simple data model or two tracks with one
%   track that spawns a secondary track
%
% Inputs:
%   motion_model_F - state transition matrix  - size [nx,nx]
%   num_timestep - number of timesteps to generate (typically 100)
%
% Outputs:
%   truth_data - data structure of truth data
%       truth_data.num_timestep - total number of timesteps
%       truth_data.state - state of targets at individual timesteps
%       truth_data.num_targets - number of targets at individual timesteps
%
% Modified by Deanna Phillips - 3/3/2023

function truth = generate_truth_simple(motion_model_F,num_timestep)

%% Setup output
truth.num_timestep=num_timestep;

 % Ground truth for states of targets
truth.state = cell(truth.num_timestep,1);     

 % Ground truth for number of targets
truth.num_targets = zeros(truth.num_timestep,1);      

%% Track information
% Track 1:
xstart(:,1)  = [ 300; 2; 300; -12 ]; % [posX; velX; posY; velY]
tbirth(1)  = 1;  % [s] Track is born at the start of the simulation
tdeath(1)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 2:
xstart(:,2) =  [ -300; 12; -300; -2 ];  % [posX; velX; posY; velY]
tbirth(2)  = 1; % [s] Track is born at the start of the simulation
tdeath(2)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 3:
xstart(:,3) = [ 445; -12; -530; -3 ]; % [posX; velX; posY; velY]
tbirth(3)  = 69; % [s] Track is born at the start of the simulation
tdeath(3)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

%% Track trajectory 
num_tracks=length(tbirth);
for targetnum = 1:num_tracks
    % Getting initial state for track defined above
    targetstate = xstart(:,targetnum);

    %Finding ending state of track
    target_end_state=min(tdeath(targetnum),truth.num_timestep);

    % Stepping through time and propogating track states
    for kk = tbirth(targetnum):target_end_state
        % Propogated state [posX; velX; posY; velY]
        targetstate = motion_model_F*targetstate;

        % Sticking together propgated states
        truth.state{kk} = [truth.state{kk} targetstate];

        % Total number of existing tracks per timestep
        truth.num_targets(kk) = truth.num_targets(kk) + 1;
    end
end

end