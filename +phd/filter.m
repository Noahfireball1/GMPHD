% [w_filter,m_filter,P_filter,filter_numbers]=phd_filter(filter_parameters,w,m,P)
% Using updated state of system, reduce the number of gaussian tracks by
% pruning, merging, capping, and extracting from the given filter
% parameters.
%
% Inputs:
%   filter_parameters - various filter parameters
%       filter_parameters.elim_thres - lower weight limit of elimination threshold (T=truncation)
%       filter_parameters.merge_thres - lower distance threshold of merging multiple tracks into one
%       filter_parameters.num_gauss_limit - upper limit to the number of allowed tracks/gaussians
%       filter_parameters.extract_threshold - lower weight threshold for extracting tracks
%   w - weights of the updated target(s) - size [1,# tracks]
%   m - states of the updated target(s) - size [nx,# tracks]
%   P - covariances of the updated target(s) - size [nx,nx,# tracks]
%
% Outputs:
%   w_filter - weights of the updated target(s) - size [nz,# new tracks]
%   m_filter - states of the updated target(s) - size [nx,# new tracks]
%   P_filter - covariances of the updated target(s) - size [nx,nx,# new tracks]
%       # new tracks = # after pruning, merging, capping and extracting
%   filter_numbers - number of gauss after each step
%       filter_numbers.num_gauss_prune - number of gaussians/tracks after pruning
%       filter_numbers.num_gauss_merge - number of gaussians/tracks after merging
%       filter_numbers.num_gauss_cap - number of gaussians/tracks after capping
%
% Needed functions: gaussian_prune,gaussian_merge,gaussian_cap
%
% Written by Deanna Phillips - 10/25/2022

function [filtered_state_estimate, filter_numbers] = filter(filter_parameters, current_timestep,state_variables)

% delete gaussians with low weight (Prune)
filtered_state_estimate = phd.prune(filter_parameters.weight_elimination,filter_parameters.prune_timesteps,current_timestep,state_variables);
filter_numbers.num_gauss_prune = length(filtered_state_estimate.weight);

% merge gaussians close to each other (Merge)
filtered_state_estimate = phd.merge(filter_parameters.merge_thres,filtered_state_estimate);
filter_numbers.num_gauss_merge = length(filtered_state_estimate.weight);

% final pruning, by only keeping the largest-weight N number of gaussians (Capping)
filtered_state_estimate = phd.cap(filter_parameters.num_gauss_limit,filtered_state_estimate);
filter_numbers.num_gauss_cap = length(filtered_state_estimate.weight);

end