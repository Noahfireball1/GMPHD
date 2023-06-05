%% Formatting
clc
clear
close all
format shortg


%% Creating an instance of the filter class and setting properties
gmphd = GMPHD();

% Initializing Properties
gmphd.Initialization.scenario = 'simple';
gmphd.Initialization.initTime = 1;
gmphd.Initialization.finalTime = 100;
gmphd.Initialization.timeStep = 1;

% Birth Properties
gmphd.Predict.birth.numBirths = 100;
gmphd.Predict.birth.staticWeight = 0.05;
gmphd.Predict.birth.staticStateRange = [-1000 1000 -25 25];
gmphd.Predict.birth.staticCovariance = diag([4 1 4 1]);

% Spawn Properties
gmphd.Predict.spawn.numSpawns = 100;
gmphd.Predict.spawn.staticWeight = 0.4;
gmphd.Predict.spawn.staticCovariance = diag([4 1 4 1]);

% Predict Properties
gmphd.Predict.pSurvival = 0.9; % Probability that track survies next timestep

% Observation Properties
gmphd.Observations.measVar = 9;
gmphd.Observations.lambda = 1; % Amount of noise added to measurements
gmphd.Observations.clutterXRange = [-1000 1000];
gmphd.Observations.clutterYRange = [-1000 1000];

% Update Properties
gmphd.Update.pDetection = 0.98;

% Prune Properties
gmphd.Prune.threshold = 0.1;

% Extract Properties
gmphd.Extraction.threshold = 0.4;


%% Loading in scenario and generating truth tracjectories
gmphd.Initialization.genTruth();

%% Running Filter
time0 = gmphd.Initialization.initTime;
time1 = gmphd.Initialization.finalTime;
dTime = gmphd.Initialization.timeStep;

for timeStep = time0:time1

    % Step 1: Predict New Objects
    gmphd.Predict.timeStep = dTime;
    gmphd.Predict.prediction();

    % Step 2: Gather Measurements
    gmphd.Observations.truth = gmphd.Initialization.state{timeStep,:};
    gmphd.Observations.getMeasurements();

    % Step 3: Propagates Estimates with Measurements (Kalman Filter)
    gmphd.Update.measurements = gmphd.Observations.measurements;
    gmphd.Update.weights = gmphd.Predict.predWeights;
    gmphd.Update.states = gmphd.Predict.predStates;
    gmphd.Update.covariances = gmphd.Predict.predCovariances;
    gmphd.Update.updating(dTime);

    % Step 4: Throw Out Weak Estimates
    gmphd.Prune.weights = gmphd.Update.updWeights;
    gmphd.Prune.states = gmphd.Update.updStates;
    gmphd.Prune.covariances = gmphd.Update.updCovariances;
    gmphd.Prune.pruning();

    % Step 5: Extract Strong Estimates
    gmphd.Extraction.weights = gmphd.Prune.prunedWeights;
    gmphd.Extraction.states = gmphd.Prune.prunedStates;
    gmphd.Extraction.covariances = gmphd.Prune.prunedCovariances;
    gmphd.Extraction.extracting();

    % Step 6: Assigning Extracted States for Next Time Steps Prediction
    gmphd.Predict.weights = gmphd.Extraction.extractedWeights;
    gmphd.Predict.states = gmphd.Extraction.extractedStates;
    gmphd.Predict.covariances = gmphd.Extraction.extractedCovariances;

    % Plotting
    customPlot(gmphd,timeStep);

    % Reseting Concatinating Variables
    gmphd.Observations.reset();
    gmphd.Prune.reset();
    gmphd.Extraction.reset();
end