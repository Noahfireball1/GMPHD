%Based on Kalman equations with weight included

function predicted_state_variables = phd_single_predict(survival_probability,motion_model_F,motion_model_G,motion_model_u,motion_model_Q,state_variables)
predicted_state_variables.weight=survival_probability*state_variables.weight;
predicted_state_variables.state=motion_model_F*state_variables.state+motion_model_G*motion_model_u;
predicted_state_variables.covariance=motion_model_F*state_variables.covariance*motion_model_F'+motion_model_Q; 
predicted_state_variables.label=state_variables.label;
end