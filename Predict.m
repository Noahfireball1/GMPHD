classdef Predict < handle
    %PREDICT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        pSurvival = 0.9;
        model = [];
        timeStep = [];
        weights = [];
        states = [];
        covariances = [];
        birth = [];
        spawn = [];
        numTracks = [];

        predWeights = [];
        predStates = [];
        predCovariances = [];
    end

    methods
        function obj = Predict()

            obj.birth = Birth();

            obj.spawn = Spawn();

        end

        function prediction(obj)

            obj.model = MotionModel(obj.timeStep);
            obj.spawn.predictSpawns(obj.timeStep);
            obj.birth.predictBirths();

            for track = 1:obj.numTracks

                weight = obj.weights(track);
                state = obj.states(:,track);
                covariance = obj.covariances(:,:,track);

                [predWeight,predState,predCovariance] = kalmanPropagation(weight,state,covariance);

                obj.predWeights(track) = predWeight;
                obj.predStates(:,track) = predState;
                obj.predCovariances(:,:,track) = predCovariance;

            end

            obj.combine();

        end

        function [predWeight,predState,predCovariance] = kalmanPropagation(obj,weight,state,covariance)

            predWeight = obj.pSurvival*weight;
            predState = obj.model.F*state + obj.model.G*obj.model.u;
            predCovariance = obj.model.F*covariance*obj.model.F' + obj.model.Q;

        end

        function combine(obj)

            obj.predWeights = cat(2,obj.predWeights,obj.birth.weights,obj.spawn.weights);
            obj.predStates = cat(2,obj.predStates,obj.birth.states,obj.spawn.states);
            obj.predCovariances = cat(3,obj.predCovariances,obj.birth.covariances,obj.spawn.covariances);

            obj.numTracks = length(obj.predWeights);


        end
    end
end

