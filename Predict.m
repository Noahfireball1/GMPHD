classdef Predict < handle
    %PREDICT uses specified motion model to propagate estimated objects positions

    properties

        % User-Defined Properties
        pSurvival {mustBePositive,mustBeNumeric} = 0.9; % Probability that object survives into next timestep

        % Set by filter
        model                                    = [];
        timeStep                                 = [];
        weights                                  = [];
        states                                   = [];
        covariances                              = [];
        birth                                    = [];
        spawn                                    = [];
        numTracks                                = [];

        % Products of Methods
        predWeights                              = [];
        predStates                               = [];
        predCovariances                          = [];
        
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
            obj.numTracks = length(obj.weights);

            for track = 1:obj.numTracks

                weight = obj.weights(track);
                state = obj.states(:,track);
                covariance = obj.covariances(:,:,track);

                [predWeight,predState,predCovariance] = obj.kalmanPropagation(weight,state,covariance);

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

            obj.predWeights = cat(2,obj.predWeights,obj.birth.birthWeights,obj.spawn.weights);
            obj.predStates = cat(2,obj.predStates,obj.birth.birthStates,obj.spawn.states);
            obj.predCovariances = cat(3,obj.predCovariances,obj.birth.birthCovariances,obj.spawn.covariances);

            obj.numTracks = length(obj.predWeights);


        end
    end
end

