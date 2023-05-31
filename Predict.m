classdef Predict
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
            obj.birth.predictBirths();
            obj.spawn.predictSpawns();

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

        function obj = combine(obj)

            obj.predWeights = cat(2,obj.predWeights,obj.birth.weights,obj.spawn.weights);
            obj.predStates = cat(2,obj.predStates,obj.birth.state,obj.spawn.state);
            obj.predCovariances = cat(3,surviving_state_variables.covariance,birth_state_variables.covariance,spawn_state_variables.covariance);


        end
    end
end

