% [w_update,m_update,P_update]=phd_update(model,filter_parameters,measurement,w,m,P)
% Using current state of the system and the filter parameters of the
% probability of detection and false alarm number, update the system based
% on current observations
%
% Inputs:
%   model - dyanamic model of the system
%       model.H - observation matrix  - size [nz,nx]
%       model.I - Identity matrix - size [nx,nx]
%       model.R - Measurement uncertainity - size [nz,nz]
%       model.x_dim - number of states
%   filter_parameters - various filter parameters
%       filter_parameters.P_detection - probability of detection
%       filter_parameters.lambda - false alarm number
%       filter_parameters.noise_density - inverse volume of region of interest
%   measurement - observations or current measurement of the system - size [nz,# observed targets]
%   w - weights of the current target(s) - size [1,# tracks]
%   m - states of the current target(s) - size [nx,# tracks]
%   P - covariances of the current target(s) - size [nx,nx,# tracks]
%
% Outputs:
%   w_update - weights of the updated target(s) - size [nz,# new tracks]
%   m_update - states of the updated target(s) - size [nx,# new tracks]
%   P_update - covariances of the updated target(s) - size [nx,nx,# new tracks]
%       # new tracks = # original tracks + (# measurements)(# original tracks)
%
% Written by Deanna Phillips - 10/25/2022
% Modified by Elizabeth Schloss - 1/12/2023
% Modified by Deanna Phillips - 03/04/23 - Cleaned up code

function update_table_state_variables=phd_update(motion_model,filter_parameters,measurement,state_variables)

%% Initial setup
num_tracks=length(state_variables.weight);
num_measurements=size(measurement,2);

%Preallocation
update_table_state_variables.weight=zeros([num_tracks, num_measurements+1]);
update_table_state_variables.state=cell([num_tracks, num_measurements+1]);
update_table_state_variables.covariance=cell([num_tracks, num_measurements+1]);

%% PHD update (in the case where no target has been detected)
for ii=1:num_tracks
    update_table_state_variables.weight(ii,1)=(1-filter_parameters.P_detection) * state_variables.weight(ii);
    update_table_state_variables.state{ii,1}=state_variables.state(:,ii);
    update_table_state_variables.covariance{ii,1}=state_variables.covariance(:,:,ii);
end

%% PHD update (in the case where all targets are detected)
if num_tracks~=0
    for meas_num=1:num_measurements
        %Updating weight, state, and covariance for each track for a single measurement
        for ii=1:num_tracks
            %Finding single updated state variables
            single_state_variable.weight=state_variables.weight(ii);
            single_state_variable.state=state_variables.state(:,ii);
            single_state_variable.covariance=state_variables.covariance(:,:,ii);
            single_updated_state_variables = other.phd_single_update(measurement(:,meas_num),filter_parameters.P_detection,motion_model.H,motion_model.I,motion_model.R,single_state_variable);

            %Saving output into structure
            update_table_state_variables.weight(ii,meas_num+1)=single_updated_state_variables.weight;
            update_table_state_variables.state{ii,meas_num+1}=single_updated_state_variables.state;
            update_table_state_variables.covariance{ii,meas_num+1}=single_updated_state_variables.covariance;
        end

    %Re-normalize w
    weight_sum=sum(update_table_state_variables.weight(:,meas_num+1));
    new_weight_sum=((filter_parameters.lambda * filter_parameters.noise_density) + weight_sum);

    %Update components
    update_table_state_variables.weight(:,meas_num+1)=update_table_state_variables.weight(:,meas_num+1)./new_weight_sum;

end



end



