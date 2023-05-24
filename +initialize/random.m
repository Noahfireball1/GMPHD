

function state_variables=initialize_random_data(num_initial_target,num_states,label_values,state_range)

state_variables.weight=zeros(1,num_initial_target);
state_variables.state=zeros(num_states,num_initial_target);
state_variables.covariance=zeros(num_states,num_states,num_initial_target);
state_variables.label=zeros(1,num_initial_target);

for ii = 1:num_initial_target
    state_variables.weight(1,ii) = 0.1;
    state_variables.state(:,ii) = state_range(:,1)+(state_range(:,2)-state_range(:,1) ).* rand(num_states,1);
    state_variables.covariance(:,:,ii) = diag([10,10,10,10]); %size: [n_x,n_x]
    state_variables.label(ii)=label_values.V_unconfirmed+ii;
end

end
