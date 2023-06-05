classdef Update < handle
    %UPDATE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        
        % User-Defined Properties
        pDetection {mustBeNumeric,mustBePositive} = 0.98;
        
        % Set by Filter
        weights = [];
        states = [];
        covariances = [];
        model = [];
        numTracks = [];
        measurements = [];

        % Products of Methods
        updWeights = [];
        updStates = [];
        updCovariances = [];

    end

    methods
        function updating(obj,dt)

            obj.model = MotionModel(dt);
            obj.numTracks = length(obj.weights);

            % Step A: Construct Kalman Components
            [eta,S,K,P] = obj.kalmanComponents();

            % Step B1: Update Objects if no detected measurements
            if isempty(obj.measurements)
                obj.noDetections();
            else
                % Step B2: Posteriori Kalman Update
                obj.kalmanPropagation(eta,S,K,P);
            end

        end

        function [eta,S,K,P] = kalmanComponents(obj)

            for track = 1:obj.numTracks

                eta(:,track) = obj.model.H*obj.states(:,track);
                S(:,:,track) = obj.model.R + obj.model.H*obj.covariances(:,:,track)*obj.model.H';
                K(:,:,track) = obj.covariances(:,:,track)*obj.model.H'*S(:,:,track)^-1;
                P(:,:,track) = (eye(4) - K(:,:,track)*obj.model.H)*obj.covariances(:,:,track);

            end

        end

        function noDetections(obj)

            for track = 1:obj.numTracks

                obj.updWeights(track) = (1 - obj.pDetection)*obj.weights(track);
                obj.updStates(:,track) = obj.states(:,track);
                obj.updCovariances(:,:,track) = obj.covariances(:,:,track);

            end

        end

        function kalmanPropagation(obj,eta,S,K,P)

            l = 0;
            for meas = 1:length(obj.measurements)
                l = l + 1;
                for track = 1:obj.numTracks
                    idx = l*obj.numTracks + track;

                    obj.updWeights(idx) = obj.pDetection*obj.weights(track)*mvnpdf(obj.measurements(:,meas), eta(:,track), S(:,:,track));
                    obj.updStates(:,idx) = obj.states(:,track) + K(:,:,track)*(obj.measurements(meas) - eta(:,track));
                    obj.updCovariances(:,:,idx) = P(:,:,track);

                end

                obj.normalizeWeight(l,meas);
            end

            obj.numTracks = l*track + track;

        end

        function normalizeWeight(obj,l,meas)

            weightTally = 0;
            getCI = Observations();

            for i = 1:obj.numTracks

                idx = l*obj.numTracks + i;
                weightTally = weightTally + obj.updWeights(idx);

            end

            for track = 1:obj.numTracks

                oldWeight = obj.updWeights(l*obj.numTracks + track);
                newWeight = oldWeight/(getCI.clutterIntensity(obj.measurements(:,meas)) + weightTally);

                obj.updWeights(l*obj.numTracks + track) = newWeight;

            end

        end

    end
end

