% model = generate_model_4states_2meas(delta_t,sigma_Q,sigma_R)
% Using given delta t, measurement error (sigma_R), and system error
% (sigma_Q), generate dynamic model structure with two measurements [x,y]
% and four states [x,vx,y,vy]
%
% Inputs:
%   delta_t - length of one time step for motion model
%   sigma_Q - system error or process noise uncertainity multiplier
%   sigma_R - measurement uncertainity multiplier
%
% Outputs: 
%   model - motion model with constant velocity
%       model.delta_t - given delta_t 
%       model.F - state transition matrix  - size [nx,nx]
%       model.u - control/input variables - size [nu,1]
%       model.G - control matrix - size [nx,nu]
%       model.sigma_Q - given sigma_Q
%       model.Q - process noise uncertainty - size [nx,nx]
%       model.sigma_R - given sigma_R
%       model.R - Measurement uncertainity - size [nz,nz]
%       model.H - observation matrix  - size [nz,nx]
%       model.x_dim - number of states
%       model.z_dim - number of measurements
%       model.I - Identity matrix - size [nx,nx]
%
% Written by Deanna Phillips - 12/22/2022

function model = generate_model_4states_2meas(delta_t,sigma_Q,sigma_R)

%% Model parameters
model.delta_t = delta_t;

% state transition - size: [n_x,n_x]
%Position and Velocity in X,Y assuming constant velocity
model.F = [1 model.delta_t 0 0; %x
    0 1 0 0; %vx
    0 0 1 model.delta_t; %y
    0 0 0 1]; %vy

model.G=0;
model.u=0;

% process uncertainty (state, system noise, model noise, etc) - size: [n_x,n_x]
model.sigma_Q = sigma_Q;
q1 = [(model.delta_t^4) / 4, (model.delta_t^3) / 2; ...
    (model.delta_t^3) / 2, model.delta_t^2]; %assume no correlation between x and y axis
Qa=[q1,zeros(2);
    zeros(2),q1];

model.Q = model.sigma_Q.^2 * Qa;

% measurement uncertainty - size: [n_z,n_z]
model.sigma_R = sigma_R;
model.R = model.sigma_R.^2 * eye(2); 

% map state to measurement - size:  [n_z,n_x]
%Measurement is [x,y] to state of [x,vx,y,vy]
model.H = [1,0,0,0; 
    0,0,1,0]; 

%Useful parameters
model.x_dim=size(model.F,1);
model.z_dim=size(model.R,1); 
model.I = eye(model.x_dim); %size: [n_x,n_x]

end