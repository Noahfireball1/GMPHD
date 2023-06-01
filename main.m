%% Formatting
clc
clear
close all
format shortg

%% Creating an instance of the filter class and setting properties
gmphd = GMPHD();


%% Loading in scenario and generating truth tracjectories
gmphd.Initialization.scenario = 'simple';
gmphd.Initialization.genTruth();

%% Running Filter

time0 = gmphd.Initialization.initTime;
time1 = gmphd.Initialization.finalTime;
dTime = gmphd.Initialization.timeStep;

for timestep = time0:time1

% Step 1: Predict New Objects
gmphd.Predict.timeStep = dTime;
gmphd.Predict.prediction();

% Step 2: Gather Measurements
% gmphd.Observations.truth = gmphd.Initialization.state{timestep};
% gmphd.Observations.getMeasurements();

% Step 3: Propagates Estimates with Measurements (Kalman Filter)

% Step 4: Throw Out Weak Estimates

% Step 5: Extract Strong Estimates




end