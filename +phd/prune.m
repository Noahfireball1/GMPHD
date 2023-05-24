% [w_new,m_new,P_new] = gaus_prune(elim_thres,w,m,P)
% Given the state of the system, return tracks above given weight threshold
%
% Inputs:
%   elim_thres - lower weight limit of elimination threshold (T=truncation)
%   w - weights of the target(s) - size [1,# tracks]
%   m - states of the target(s) - size [nx,# tracks]
%   P - covariances of the target(s) - size [nx,nx,# tracks]
%
% Outputs:
%   w_new - weights of the updated target(s) - size [nz,# new tracks]
%   m_new - states of the updated target(s) - size [nx,# new tracks]
%   P_new - covariances of the updated target(s) - size [nx,nx,# new tracks]
%
% Written by Deanna Phillips - 10/25/2022
% Modified by Deanna Phillips - 03/05/2023 - cleaned up and modified output

function new_state_variables = prune(elim_thres,prune_timesteps,current_timestep,state_variables)

%% Step 1 - Set the weight to zero for labels without states for # of windows

if current_timestep==1
    no_state_timesteps=[];
elseif current_timestep <= prune_timesteps
    no_state_timesteps=2:current_timestep; %current_time-1, current_time-2, current_time-3
else
    no_state_timesteps=current_timestep-prune_timesteps+1:current_timestep;
end

for jj=1:length(no_state_timesteps)
    %Find indices where state labels are apart of the no state list
    idx=ismember(state_variables.label(ii),no_state_label_set{no_state_timesteps(jj)-1});

    if idx==false %If it is not a member of the no state label set, then there is a state and should not be pruned
        break %stop testing this label
    end
end

% If it completes last loop, label is apart of the no state label set
% so change weight to prune out
if jj==length(no_state_timesteps)
    state_variables.weight(ii)=0;
end

%% Step 2 - Eliminate weights below threshold
%Finding weights below threshold or NaN weights
idx = (state_variables.weight <= elim_thres) | isnan(state_variables.weight);

%Eliminating the tracks below threshold
new_state_variables.weight=state_variables.weight(~idx);
new_state_variables.state=state_variables.state(~idx,:);
new_state_variables.covariance=state_variables.covariance(:,:,~idx);

end