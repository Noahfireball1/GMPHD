classdef Spawn < handle
    %SPAWN creates estimates off existing tracks based on their states
    
    properties

        % User-Defined Properties
        numSpawns        {mustBeNumeric,mustBePositive,mustBeInteger} = 100;
        staticWeight     {mustBeNumeric,mustBePositive}               = 0.2;
        staticCovariance {mustBeNumeric}                              = diag([1 0.5 1 0.5]);
        
        % Set by Filter
        numTracks = [];
        weights = [];
        states = [];
        covariances = [];
        model = [];

        % Products of Methods
        predWeights = [];
        predStates = [];
        predCovariances = [];
    end
    
    methods        
        function obj = predictSpawns(obj,timeStep)
            
            obj.model = MotionModel(timeStep);
            obj.numTracks = length(obj.weights);

            idx = 1;
            for spawn = 1:obj.numSpawns
                for track = 1:obj.numTracks
                    obj.predWeights(idx) = obj.weights(track)*obj.staticWeight;
                    obj.predStates(:,idx) = obj.model.F*obj.states(:,track);
                    obj.predCovariances(:,:,idx) = obj.staticCovariance + (obj.model.F*obj.covariances(:,:,track)*obj.model.F');

                    idx = idx + 1;
                end
            end

            
        end
    end
end

