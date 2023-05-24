% truth = generate_truth_simple(motion_model_F,num_timestep)
% Generate truth data for the OSPA data model or multiple, predefined tracks 
%   with criss crosses and births. No spawning tracks. 
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


function truth = generate_truth_ospa(motion_model_F,num_timestep)

%% Setup output
truth.num_timestep=num_timestep;

 % Truth for states of targets
truth.state = cell(truth.num_timestep,1);     

 % Truth for number of targets
truth.num_targets = zeros(truth.num_timestep,1);      

%% Track information
% Track 1:
xstart(:,1) = [0; 0; 0; -10]; % [posX; velX; posY; velY]
tbirth(1)  = 1;  % [s] Track is born at the start of the simulation
tdeath(1)  = 70; % [s] Track dies at the 70th second

% Track 2:
xstart(:,2) = [400; -10; -600; 5]; % [posX; velX; posY; velY]
tbirth(2)  = 1; % [s] Track is born at the start of the simulation
tdeath(2)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 3:
xstart(:,3) = [-800; 20; -200; -5]; % [posX; velX; posY; velY]
tbirth(3)  = 1; % [s] Track is born at the start of the simulation
tdeath(3)  = 70; % [s] Track dies at the 70th second

% Track 4:
xstart(:,4) = [400; -7; -600; -4]; % [posX; velX; posY; velY]
tbirth(4)  = 20;  % [s] Track is born at 20 seconds
tdeath(4)  = truth.num_timestep+1;  % [s] Track survives the entire length of the simulation

% Track 5:
xstart(:,5) = [400; -2.5; -600; 10]; % [posX; velX; posY; velY]
tbirth(5)  = 20;  % [s] Track is born at 20 seconds
tdeath(5)  = truth.num_timestep+1;  % [s] Track survives the entire length of the simulation

% Track 6:
xstart(:,6) = [0; 7.5; 0; -5]; % [posX; velX; posY; velY]
tbirth(6)  = 20; % [s] Track is born at 20 seconds
tdeath(6)  = truth.num_timestep+1;  % [s] Track survives the entire length of the simulation

% Track 7:
xstart(:,7) = [-800; 12; -200; 7]; % [posX; velX; posY; velY]
tbirth(7)  = 40;  % [s] Track is born at 40 seconds
tdeath(7)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 8:
xstart(:,8) = [-200; 15; 800; -10]; % [posX; velX; posY; velY]
tbirth(8)  = 40;  % [s] Track is born at 40 seconds
tdeath(8)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 9:
xstart(:,9) = [-800; 3; -200; 15]; % [posX; velX; posY; velY]
tbirth(9)   = 60;  % [s] Track is born at 60 seconds
tdeath(9)  = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 10:
xstart(:,10) = [-200; -3; 800; -15]; % [posX; velX; posY; velY]
tbirth(10)  = 60;  % [s] Track is born at 60 seconds
tdeath(10) = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 11:
xstart(:,11) = [0; -20; 0; -15]; % [posX; velX; posY; velY]
tbirth(11)  = 80;  % [s] Track is born at 80 seconds
tdeath(11) = truth.num_timestep+1; % [s] Track survives the entire length of the simulation

% Track 12:
xstart(:,12) = [-200; 15; 800; -5]; % [posX; velX; posY; velY]
tbirth(12)  = 80;  % [s] Track is born at 80 seconds
tdeath(12) = truth.num_timestep+1; % [s] Track survives the entire length of the simulation


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