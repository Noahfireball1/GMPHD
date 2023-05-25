classdef Update < handle
    %UPDATE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        model = [];
        pDetection = [];
        numTracks = [];

        weights = [];
        states = [];
        covariances = [];

        updWeights = [];
        updStates = [];
        updCovariances = [];

    end

    methods
        function outputArg = updating(obj,dt)

            obj.model = MotionModel(dt);
            obj.numTracks = length(obj.weights);

            % Step A: Construct Kalman Components
            [eta,S,K,P] = obj.kalmanComponents();

            % Step B1: Update Objects if no detected measurements
            if isempty(measurements)
                obj.noDetections();
            else
                % Step B2: Posteriori Kalman Update
                obj.kalmanPropagation();
            end

        end

        function [eta,S,K,P] = kalmanComponents(obj)

            for track = 1:obj.numTracks

                eta(:,track) = obj.model.H*obj.states(:,track);
                S(:,:,track) = obj.model.R + obj.model.H*obj.covariances(:,:,track)*obj.model.H';
                K(:,track) = obj.covariances(:,:,track)*obj.model.H'\S(:,:,track);
                P(:,:,track) = (eye(size(K(track))) - K(track)*obj.model.H)*obj.covariances(:,:,track);

            end

        end

        function noDetections(obj)

            for track = 1:obj.numTracks

                obj.updWeights(track) = (1 - obj.pDetection)*obj.weights(track);
                obj.updStates(:,track) = obj.states(:,track);
                obj.updCovariances(:,:,track) = obj.covariances(:,:,track);

            end

        end

        function kalmanPropagation(obj,measurements,eta,S,K,P)

            l = 0;
            for meas = 1:length(measurements)
                l = l + 1;
                for track = 1:obj.numTracks
                    idx = l*obj.numTracks + track;

                    obj.updWeights(idx) = obj.pDetection*obj.weights(track)*mvnpdf(measurements(meas), eta(:,track), S(:,:,track));
                    obj.updStates(:,idx) = obj.states(:,track) + K(:,track)*(measurements(meas) - eta(:,track));
                    obj.updCovariances(:,:,idx) = P(:,:,track);

                end

                obj.normalizeWeight(idx);
            end

            obj.numTracks = l*track + track;

        end

        function normalizeWeight(obj,l,meas,measurements)

            weightTally = 0;
            getCI = Observations();

            for i = 1:obj.numTracks

                idx = l*obj.numTracks + i;
                weightTally = weightTally + obj.updWeights(idx);

            end

            for track = 1:obj.numTracks

                oldWeight = obj.updWeights(l*obj.numTracks + track);
                newWeight = oldWeight/(getCI.clutterIntensity(measurements(meas)) + weightTally);

                obj.updWeights(l*obj.numTracks + track) = newWeight;

            end

        end

    end
end

