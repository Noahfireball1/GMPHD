% [w_new,m_new,P_new] = gaus_cap(num_gauss_limit,w,m,P) 
% Given the state of the system, return limit of highest weight tracks.
%
% Inputs:
%   num_gauss_limit - upper limit to the number of allowed tracks/gaussians
%       if threshold=-1, skips capping
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

function new_state_estimate = gaussian_cap(num_gauss_limit,state_estimate) 
%Checking for skip condition
if num_gauss_limit==-1
    new_state_estimate.weight=state_estimate.weight;
    new_state_estimate.state=state_estimate.state;
    new_state_estimate.covariance=state_estimate.covariance;
    new_state_estimate.label=state_estimate.label;
    fprintf('Not capping\n');
    return
end

if length(state_estimate.weight) > num_gauss_limit
    %Sorting by highest weight
    [~, idx] = sort(state_estimate.weight, 'descend');

    %Extracting top # of targets
    new_state_estimate.weight=state_estimate.weight(idx(1:num_gauss_limit));
    new_state_estimate.weight = new_state_estimate.weight * (sum(state_estimate.weight)/sum(new_state_estimate.weight)); %reweighting
    new_state_estimate.state=state_estimate.state(:,idx(1:num_gauss_limit));
    new_state_estimate.covariance=state_estimate.covariance(:,:,idx(1:num_gauss_limit));
    new_state_estimate.label=state_estimate.label(idx(1:num_gauss_limit));
else
    new_state_estimate.weight=state_estimate.weight;
    new_state_estimate.state=state_estimate.state;
    new_state_estimate.covariance=state_estimate.covariance;
    new_state_estimate.label=state_estimate.label;
end

end