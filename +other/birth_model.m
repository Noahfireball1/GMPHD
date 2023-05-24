% [w_birth,m_birth,P_birth]=birth_model(birth_parameters)
% Using given birth parameters, randomly choose the starting state for new
% objects with given weight and covariance. 
%
% Inputs:
%   birth_parameters
%       birth_parameters.num_births - number of birth targets to estimate
%       birth_parameters.state_range - max and min values for each state for the new targets to spawn from - size [nx,2]
%       birth_parameters.weights - weights for the new target(s) - size [1,1]
%       birth_parameters.covariance - covariances values for the new target(s) (just the diagonal values, not full matrix) - size [1,nx]
%
% Outputs: 
%   w_birth - weights of the new target(s) - size [nz,# birth tracks]
%   m_birth - states of the new target(s) - size [nx,# birth tracks]
%   P_birth - covariances of the new target(s) - size [nx,nx,# birth tracks]
%
% Written by Deanna Phillips - 10/25/2022
% Modified by Deanna Phillips - 03/04/2023 - Changed output structures and added labels

function birth_state_variables=birth_model(birth_parameters)

% Parse out parameter for easy access
num_births=birth_parameters.num_births;
birth_state_range=birth_parameters.state_range;
birth_weights=birth_parameters.weights;
birth_covariance=birth_parameters.covariance;

% Preallocate variables
num_states=size(birth_state_range,1)*2;
birth_state_variables.weight=zeros(1,num_births);
birth_state_variables.state=zeros(num_states,num_births);
birth_state_variables.covariance=zeros(num_states,num_states,num_births);
birth_state_variables.label=zeros(1,num_births);

%Assign new birth gaussians with predefined weights, states, covariances and labels
for ii=1:num_births
    birth_state_variables.weight(ii) = birth_weights;
    birth_state_variables.state(:,ii)= [randi(birth_state_range(1,:),1) randi(birth_state_range(2,:),1) randi(birth_state_range(1,:),1) randi(birth_state_range(2,:),1)]';
    birth_state_variables.covariance(:,:,ii)=birth_covariance;
end

end
