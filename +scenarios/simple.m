function tracker_options = simple()
%% Options
tracker_options.num_timestep = 100; 
tracker_options.delta_t = 1;

%% Motion Model parameters
sigma_Q = 5; % process uncertainty (state, system noise, model noise, etc)
sigma_R = 5; % measurement uncertainty
tracker_options.motion_model = generate.model_4states_2meas(tracker_options.delta_t,sigma_Q,sigma_R);

%% PHD tracker filter parameters
%Filter probabilities
filter.P_detection = 0.9; % detection rate (% of detecting an object)
filter.P_survival = 0.99; % survival rate (% of an object to survive in this timestep)

%Filter limits
filter.prune_timesteps = 3;
filter.merge_thres = 4; % U
filter.num_gauss_limit = 50; % Jmax
filter.gating_coeff = 15;

%Filter false alarm settings
filter.lambda = 0.25; % false alarm number %choosen by lamada distribution
filter.clutter_region=[-1000 1000; %x_range
    -1000 1000]; %y_range
filter.noise_density=1/(diff(filter.clutter_region(1,:))*diff(filter.clutter_region(2,:))); %1/(x_range*y_range)

%Filter weight thresholds
filter.weight_elimination=1e-3; %T (truncation threshold or elimination);
filter.weight_basic = 0.02;
filter.weight_small = 0.1;
filter.weight_medium = 0.2;
filter.weight_large = 0.4;
filter.weight_extract = 0.5; %extract states with weight above this threshold
filter.weight_multiplier=0.3;

tracker_options.filter_parameters=filter;

%% PHD new parameter options
%Birth parameters - same weight and covariance for all births but random state range
birth_parameters.num_births = 100;
birth_parameters.weights = 0.5;
birth_parameters.covariance = diag([50,25,50,25]);
birth_parameters.state_range = [-1000 1000;0 10];
tracker_options.birth_parameters = birth_parameters;

%Spawn parameters - same weight and covariance for all spawn but use previous state
spawn_parameters.num_spawns=1;
spawn_parameters.weights=repelem(0.03,spawn_parameters.num_spawns);
spawn_parameters.covariance=repmat(diag([10,10,10,10]),[1,1,spawn_parameters.num_spawns]);
spawn_parameters.F=tracker_options.motion_model.F;
tracker_options.spawn_parameters=spawn_parameters;

%% Target initialization
tracker_options.initial_target_num = 1000; %Initial target guess

%Calculate initial state variables
initial_state_variables = initialize.simple(tracker_options.initial_target_num,tracker_options.motion_model.x_dim,birth_parameters.state_range);
tracker_options.initial_state_variables=initial_state_variables;

end





