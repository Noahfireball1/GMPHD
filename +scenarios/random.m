function tracker_options = random()
%% Options
tracker_options.num_timestep = 20; 
tracker_options.delta_t = 1;

%% Motion Model parameters
sigma_Q = 5; % process uncertainty (state, system noise, model noise, etc)
sigma_R = 5; % measurement uncertainty
tracker_options.motion_model = generate_model_4states_2meas(tracker_options.delta_t,sigma_Q,sigma_R);

%% PHD truth parameters
tracker_options.birth_probability = 0.20; %birth probability %% Only needed for generating truth measurements and random

%% PHD tracker filter parameters
%Filter probabilities
filter.P_detection = 0.99; % detection rate (% of detecting an object)
filter.P_survival = 0.95; % survival rate (% of an object to survive in this timestep)

%Filter limits
filter.prune_timesteps=10;
filter.merge_thres=4; % U
filter.num_gauss_limit= 50; % Jmax
filter.gating_coeff=6;

%Filter false alarm settings
filter.lambda = 0; % false alarm number %choosen by lamada distribution
filter.clutter_region=[-1000 1000; %x_range
    -1000 1000]; %y_range
filter.noise_density=1/(diff(filter.clutter_region(1,:))*diff(filter.clutter_region(2,:))); %1/(x_range*y_range)

%Filter weight thresholds
filter.weight_elimination=1e-4; %T (truncation threshold or elimination);
filter.weight_basic = 0.02;
filter.weight_small = 0.1;
filter.weight_medium = 0.2;
filter.weight_large = 0.4;
filter.weight_extract = 0.5; %extract states with weight above this threshold
filter.weight_multiplier=0.3;

tracker_options.filter_parameters=filter;

%% PHD label parameters
tracker_options.label_values.V_unconfirmed=200;
tracker_options.label_values.V_new=400;
tracker_options.label_values.r_max_confirmed=0;
tracker_options.label_values.r_max_unconfirmed=tracker_options.label_values.V_unconfirmed;

%% Target initialization
%Initial numbers - only for random data
tracker_options.initial_target_num = 10; %Initial target guess
tracker_options.state_range= [-800,800; %x_min,x_max
    0,10; %vel_x_min, vel_x_max
    -800,800; %y_min,y_max
    0,10]; %vel_y_min, vel_y_max

%Calculate initial state variables
initial_state_variables=initialize_random_data(tracker_options.initial_target_num,tracker_options.motion_model.x_dim,tracker_options.label_values,tracker_options.state_range);
tracker_options.initial_state_variables=initial_state_variables;

%% PHD new parameter options
%Birth parameters - same weight and covariance for all births but random state range 
%Later mess with making it random at start versus dynamically random in birth model
birth_parameters.num_births=50;
birth_parameters.weights=repelem(0.03,birth_parameters.num_births);
birth_parameters.covariance=repmat(diag([100,100,100,100]),[1,1,birth_parameters.num_births]);
birth_parameters.state_range=tracker_options.state_range(:,1)+(tracker_options.state_range(:,2)-tracker_options.state_range(:,1) ).* rand(tracker_options.motion_model.x_dim,birth_parameters.num_births);
tracker_options.birth_parameters=birth_parameters;

%Spawn parameters - same weight and covariance for all spawn but use previous state
spawn_parameters.num_spawns=0;
spawn_parameters.weights=repelem(0.03,spawn_parameters.num_spawns);
spawn_parameters.covariance=repmat(diag([10,10,10,10]),[1,1,spawn_parameters.num_spawns]);
spawn_parameters.F=tracker_options.motion_model.F;
tracker_options.spawn_parameters=spawn_parameters;

end





