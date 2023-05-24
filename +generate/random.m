% truth = generate_truth_random(motion_model,birth_probability,survival_probability,initial_state,initial_target_num,num_timestep)
% Generates purely random data based on a gaussian distribution with a
%   given motion model and state range
%
% Inputs:
%   motion_model - motion model
%       motion_model.F - state transition matrix  - size [nx,nx]
%       motion_model.Q - process noise uncertainty - size [nx,nx]
%       motion_model.x_dim - number of states
%   birth_probability - new target birth probability or how likely new
%       track will appear
%   survival_probability - survival probability or how likely track
%       will be to survivie
%   initial_state - initial state of target
%   initial_target_num - inital number of targets
%   num_timestep - number of timesteps to generate
%
% Outputs:
%   truth_data - data structure of truth data
%       truth_data.num_timestep - total number of timesteps
%       truth_data.state - state of targets at individual timesteps
%       truth_data.num_targets - number of targets at individual timesteps
%
% Needed functions: mvnrnd
%
% Written by Deanna Phillips - 10/25/2022
% Modified by Deanna Phillips - 3/3/2023

function truth_data = generate_truth_random(motion_model,birth_probability,survival_probability,state_range,initial_target_num,num_timestep)

%% Setup output
truth_data.state = cell(num_timestep, 1); % truth state (position and velocity)
truth_data.num_targets = zeros(num_timestep, 1); % number of targets for each time
truth_data.num_timestep=num_timestep;

%% Target initialization
% initialize all targets' state randomly
state_current = zeros(motion_model.x_dim,initial_target_num);
for ii = 1:initial_target_num
    state_current(:,ii)=state_range(:,1)+ (state_range(:,2)-state_range(:,1)).* rand(motion_model.x_dim, 1);
end

%Number of initial targets
num_target=initial_target_num;

%% Generate random trajectory
for kk = 1:num_timestep
    %Generate new targets
    birth_flag=true;

    %while loop allows for multiple new targets
    while birth_flag
        if rand < birth_probability % New target is present
            %Random initial state
            state_current(:,num_target+1)=state_range(:,1)+ (state_range(:,2)-state_range(:,1)).* rand(motion_model.x_dim, 1);

            %Change num targets
            num_target=num_target+1;

        else %No new targets
            birth_flag=false;
        end
    end

    % Extracting only targets that survive according to random draw
    state_extract=NaN(motion_model.x_dim,1);
    extract_target_counter=1;
    for jj = 1: num_target
        if rand < survival_probability % target survives in this timestep
            mean_x= motion_model.F * state_current(:, jj);
            guassian_dist=mvnrnd(mean_x, motion_model.Q);
            state_extract(:,extract_target_counter)=guassian_dist'; % motion model
            extract_target_counter=extract_target_counter+1;
        end
    end

    %Set new state
    state_current = state_extract;
    num_target=size(state_extract,2);

    %Saving output in structure
    truth_data.state{kk} = state_extract;
    truth_data.num_targets(kk) = size(state_extract,2);
end

end


