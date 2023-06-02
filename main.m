%% Formatting
clc
clear
close all
format shortg
figure(1)
hold on

%% Creating an instance of the filter class and setting properties
gmphd = GMPHD();

% Predict Properties

% Observation Properties

% Update Properties

% Prune Properties

% Extract Properties


%% Loading in scenario and generating truth tracjectories
gmphd.Initialization.scenario = 'simple';
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