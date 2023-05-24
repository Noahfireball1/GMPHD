% effectiveObservation = observation_selection(prediction, measurement,model)
% Minimizes the measurement matrix to only measurement that fall under a
% certain, determinstic distance
%
% Inputs:
%   prediction - struct containing predicted weight, mean, covariance, and
%   label of existing targets (including newly birthed ones)
%   measurement - struct containing measurements from truth model and
%   timestep, k
%   model - struct containing dynamic model, along with a handful of other
%   things
%
% Outputs:
%   effectiveObservation - struct containing only measurements that fall
%   under a certain threshold distance
%
% Author(s): Noah Miller
% Last Updated: 12/13/2022
% Modified by Deanna Phillips - 03/05/2023 - changed structure and output

function extract_observation = observation_selection(motion_model_R,motion_model_H,filter_gating_coeff,predicted_state,measurements)
% Useful quanities
num_tracks=size(predicted_state, 2);
num_measurements=size(measurements, 2);
num_measurements_states=size(measurements, 1);

%Preallocate
extract_observation=NaN(num_measurements_states,1); % Will expand as things are added
count_index=1;

%% Finding distance threshold
min_distance=norm(sqrt(diag(motion_model_R))); % Euclidian distance
distance_threshold = filter_gating_coeff*min_distance; % apply a gating coefficient

%% Looping through each Gaussian mixture for each target
for ii = 1:num_measurements
    for jj = 1:num_tracks
        % Determining distance from each measurement to each predicted state
        distance_gaussian = norm(measurements(:,ii) - motion_model_H*predicted_state(:,jj));

        % Determining if the current target distance from measurements falls under the threshold
        if distance_gaussian < distance_threshold
            extract_observation(:,count_index) = measurements(:,ii);
            count_index=count_index+1;
            break %track already matches observations so stop checking rest of tracks
        end
    end
end

end