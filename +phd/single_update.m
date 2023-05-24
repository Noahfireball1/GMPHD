%Based on Kalman equations with weight included



function updated_state_variables=phd_single_update(measurements,detection_probability,motion_model_H,motion_model_I,motion_model_R,state_variables)
%Helpful quantities
state_mean = motion_model_H * state_variables.state;
pre_covariance = motion_model_R + motion_model_H*state_variables.covariance*motion_model_H';
kalman_gain = state_variables.covariance*motion_model_H'*(pre_covariance)^-1;

%Update equations
updated_state_variables.weight=state_variables.weight*detection_probability*mvnpdf(measurements, state_mean, pre_covariance);
updated_state_variables.state= state_variables.state + kalman_gain*(measurements - state_mean);
updated_state_variables.covariance=(motion_model_I-kalman_gain*motion_model_H)*state_variables.covariance*(motion_model_I-kalman_gain*motion_model_H)'+(kalman_gain*motion_model_R*kalman_gain');
end