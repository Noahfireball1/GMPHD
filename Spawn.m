classdef Spawn < handle
    %SPAWN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numSpawns = 100;
        staticWeight = 0.2;
        staticCovariance = diag([1 1 1 1]);
        model = [];

        numTracks = [];
        weights = [];
        states = [];
        covariances = [];

        predWeights = [];
        predStates = [];
        predCovariances = [];
    end
    
    methods        
        function obj = predictSpawns(obj,timeStep)
            
            obj.model = MotionModel(timeStep);

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

