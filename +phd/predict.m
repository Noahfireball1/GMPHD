% [w_predict,m_predict,P_predict]=phd_predict(model,P_survival,birth_parameters,w,m,P)
% Using given dynamic model, survival rate, current state of target(s) and
%   the birth model, predict next state of target(s)
%
% Inputs:
%   model - dyanamic model of the system
%       model.F - state transition matrix  - size [nx,nx]
%       model.G - control matrix - size [nx,nu]
%       model.u - control/input variables - size [nu,1]
%       model.Q - process noise uncertainty - size [nx,nx]
%   P_survival - surivival probability (0-1)
%   w - weights of the current target(s) - size [1,# tracks]
%   m - states of the current target(s) - size [nx,# tracks]
%   P - covariances of the current target(s) - size [nx,nx,# tracks]
%   birth_parameters - various parameters to spawn new gaussians/tracks
%       birth_parameters.num_births - number of birth targets to estimate
%       birth_parameters.state_range - max and min values for each state for the new targets to spawn from - size [nx,2]
%       birth_parameters.weights - weights for the new target(s) - size [1,1]
%       birth_parameters.covariance - covariances values for the new target(s) (just the diagonal values, not full matrix) - size [1,nx]
%   spawn_parameters
%       spawn_parameters.num_spawns - number of spawn targets to estimate
%       spawn_parameters.weights - weights for the new target(s) - size [1,1]
%       spawn_parameters.covariance - covariances values for the new target(s) (just the diagonal values, not full matrix) - size [1,nx]
%       spawn_parameters.F - state transition matrix for spawning motion
%
% Outputs: 
%   w_predict - weights of the predicted target(s) - size [nz,# predicted tracks]
%   m_predict - states of the predicted target(s) - size [nx,# predicted tracks]
%   P_predict - covariances of the predicted target(s) - size [nx,nx,# predicted tracks]
%       # predicted tracks = # original tracks + # birth tracks
%
% Needed functions: birth_model
%                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
% Written by Deanna Phillips - 10/25/2022
% Modified by Elizabeth Schloss 1/12/2023 - added labels
% Modified by Deanna Phillips - 03/04/23 - Cleaned up code

function predict_state_variables = predict(motion_model,P_survival,birth_parameters,spawn_parameters,state_variables)
%% Useful quantities
num_track=length(state_variables.weight);
num_states=size(state_variables.state,1);

%% surviving components (from previous time step)
%Preallocation
surviving_state_variables.weight=zeros(1,num_track);
surviving_state_variables.state=zeros(num_states,num_track);
surviving_state_variables.covariance=zeros(num_states,num_states,num_track);

for jj = 1:num_track
    %Finding single predicted state variables
    single_state_variable.weight = state_variables.weight(jj);
    single_state_variable.state = state_variables.state(:,jj);
    single_state_variable.covariance = state_variables.covariance(:,:,jj);
    single_predicted_state_variables = other.phd_single_predict(P_survival,motion_model.F,motion_model.G,motion_model.u,motion_model.Q,single_state_variable);

    %Saving output into structure
    surviving_state_variables.weight(jj) = single_predicted_state_variables.weight;
    surviving_state_variables.state(:,jj) = single_predicted_state_variables.state;
    surviving_state_variables.covariance(:,:,jj) = single_predicted_state_variables.covariance;
end

%% birth components
birth_state_variables = other.birth_model(birth_parameters);

%% spawn components
spawn_state_variables = other.spawn_model(spawn_parameters,state_variables);

%% combine
predict_state_variables.weight = cat(2,surviving_state_variables.weight,birth_state_variables.weight,spawn_state_variables.weight);
predict_state_variables.state = cat(2,surviving_state_variables.state,birth_state_variables.state,spawn_state_variables.state);
predict_state_variables.covariance = cat(3,surviving_state_variables.covariance,birth_state_variables.covariance,spawn_state_variables.covariance);

end
