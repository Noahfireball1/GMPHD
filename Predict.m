classdef Predict
    %PREDICT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        pSurvival = 0.9;
        weights = [];
        states = [];
        covariances = [];
        birth = [];
        spawn = [];

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

        end

        function kalmanPropagation(obj)

        end
    end
end

