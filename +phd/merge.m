% [w_new,m_new,P_new] = gaus_merge(merge_threshold,w,m,P)
% Given the state of the system, merge tracks within given distance into
% one.Return both merged and non-merged tracks.
%
% Inputs:
%   merge_threshold - lower distance threshold of merging multiple tracks into one
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

function new_state_variables = gaussian_merge(merge_threshold,state_variables)
%Variables
num_tracks=1:length(state_variables.weight);  %Number of original gaussian
num_states=size(state_variables.state,1);
new_tracker_counter= 1;

%Checking for no tracks
if isempty(num_tracks)
    % no gaussians to merge
    new_state_variables.weight=state_variables.weight;
    new_state_variables.state=state_variables.state;
    new_state_variables.covariance=state_variables.covariance;
    new_state_variables.label=state_variables.label;
end

%Reshape covariance
% state_variables.covariance=reshape(state_variables.covariance, num_states, num_states,[]);

while ~isempty(num_tracks)
    %Finding state of remaining tracks
    temp_w=state_variables.weight(num_tracks);
    temp_m=state_variables.state(:,num_tracks);
    temp_P=state_variables.covariance(:,:,num_tracks);
    temp_l=state_variables.label(num_tracks);

    %Find state of the max weight
    [~, max_ind] = max(temp_w);
    max_ind=max_ind(1); %if more than one indicies
    important_mean = temp_m(:,max_ind);
    important_label = temp_l(max_ind);

    %Set up w, m, and P for current track
    new_state_variables.weight(1,new_tracker_counter)= 0;
    new_state_variables.state(:,new_tracker_counter)= zeros(num_states,1);
    new_state_variables.covariance(:,:,new_tracker_counter)= zeros(num_states,num_states);
    new_state_variables.label(1,new_tracker_counter)=0;
    merge_list = [];

    %Find tracks within merge distance that have the same label
    for jj = 1:numel(num_tracks)
        mean_dist = (temp_m(:,jj) -important_mean)' * (temp_P(:,:,jj))^-1 * (temp_m(:,jj) -important_mean);
        if mean_dist <= merge_threshold && temp_l(jj) == important_label
            merge_list = [merge_list; num_tracks(jj)];
        end
    end

    if isempty(merge_list)
        break %No tracks within merge distance so exit out of loop
    end

    %Assign new label
    new_state_variables.label(new_tracker_counter) = important_label;

    %Calculate merged weight
    new_state_variables.weight(1,new_tracker_counter)=sum(state_variables.weight(merge_list));

    %Calculate merged state
    mean_list=zeros(num_states,numel(merge_list));
    for j = 1:numel(merge_list)
        mean_list(:,j) = state_variables.state(:,merge_list(j)) * state_variables.weight(merge_list(j)) ;
    end
    new_state_variables.state(:,new_tracker_counter)=sum(mean_list,2)./new_state_variables.weight(1,new_tracker_counter);

    %Calculate merged covariance
    cov_list=zeros(num_states,num_states,numel(merge_list));
    for j = 1:numel(merge_list)
        mean_diff2 = new_state_variables.state(:,new_tracker_counter) - state_variables.state(:,merge_list(j));
        cov_list(:,:,j) = state_variables.weight(merge_list(j)) * ( state_variables.covariance(:,:,merge_list(j)) + mean_diff2 * mean_diff2');
    end
    new_state_variables.covariance(:,:,new_tracker_counter)=sum(cov_list,3)./new_state_variables.weight(1,new_tracker_counter);

    % Update numbers/tracks
    num_tracks=setdiff(num_tracks,merge_list);
    new_tracker_counter= new_tracker_counter+1;
end


end