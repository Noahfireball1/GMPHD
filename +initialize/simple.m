function state_variables = simple(num_initial_target,num_states,stateRange)

state_variables.weight=zeros(1,num_initial_target);
state_variables.state=zeros(num_states,num_initial_target);
state_variables.covariance=zeros(num_states,num_states,num_initial_target);
state_variables.label=zeros(1,num_initial_target);

for ii = 1:num_initial_target
    state_variables.weight(1,ii) = 0.01;
    state_variables.state(:,ii) = [randi(stateRange(1,:),1) randi(stateRange(2,:),1) randi(stateRange(1,:),1) randi(stateRange(2,:),1)]';
    state_variables.covariance(:,:,ii) = diag(ones(4,1)); %size: [n_x,n_x]
end

end