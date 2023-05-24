%[w_spawn,m_spawn,P_spawn]=spawn_model(spawn_parameters,w,m,P)
% Using given motion model, spawn parameters, and current state data, 
% spawn a given number of targets at the last track state with given weight and covariance. 
%
% Inputs:
%   spawn_parameters
%       spawn_parameters.num_spawns - number of spawn targets to estimate
%       spawn_parameters.weights - weights for the new target(s) - size [1,1]
%       spawn_parameters.covariance - covariances values for the new target(s) (just the diagonal values, not full matrix) - size [1,nx]
%       spawn_parameters.F - state transition matrix for spawning motion
%   w - weights of the current target(s) - size [1,# tracks]
%   m - states of the current target(s) - size [nx,# tracks]
%   P - covariances of the current target(s) - size [nx,nx,# tracks]
%
% Outputs: 
%   w_spawn - weights of the new target(s) - size [nz,# spawn tracks]
%   m_spawn - states of the new target(s) - size [nx,# spawn tracks]
%   P_spawn - covariances of the new target(s) - size [nx,nx,# spawn tracks]
%
% Written by Deanna Phillips - 01/10/2023
% Modified by Deanna Phillips - 03/04/2023 - Changed output structures and added labels

function spawn_state_variables=spawn_model(spawn_parameters,state_variables)

% Useful parameters
num_states=size(state_variables.state,1);
num_tracks=length(state_variables.weight);
spawn_weights=spawn_parameters.weights;
spawn_covariance=spawn_parameters.covariance;
motion_model_F=spawn_parameters.F;
total_num_births=spawn_parameters.num_spawns*num_tracks;

%Preallocate
spawn_state_variables.weight=zeros(1,total_num_births);
spawn_state_variables.state=zeros(num_states,total_num_births);
spawn_state_variables.covariance=zeros(num_states,num_states,total_num_births);

%Find weight, state and covariance
index=1;
for ii=1:spawn_parameters.num_spawns
    for jj=1:num_tracks
            spawn_state_variables.weight(index)=state_variables.weight(jj)*spawn_weights(ii); %track weight*spawn weight
            spawn_state_variables.state(:,index)=motion_model_F*state_variables.state(:,jj);
            spawn_state_variables.covariance(:,:,index)=spawn_covariance(:,:,ii)+motion_model_F*state_variables.covariance(:,:,jj)*motion_model_F';
            index=index+1;
    end
end

end
