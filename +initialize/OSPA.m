function state_variables=initialize_OSPA_data(num_initial_target,num_states,label_values)

state_variables.weight=zeros(1,num_initial_target);
state_variables.state=zeros(num_states,num_initial_target);
state_variables.covariance=zeros(num_states,num_states,num_initial_target);
state_variables.label=zeros(1,num_initial_target);

for ii = 1:num_initial_target
    state_variables.weight(1,ii) = eps;
    state_variables.state(:,ii) = [290,0,290,0]';
    state_variables.covariance(:,:,ii) = diag(ones(4,1)); %size: [n_x,n_x]
    state_variables.label(ii)=label_values.V_unconfirmed+ii;
end

end