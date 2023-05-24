classdef Spawn
    %SPAWN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numSpawns = [];
        staticWeight = [];
        staticCovariance = [];
        model = [];

        weights = [];
        states = [];
        covariances = [];
    end
    
    methods        
        function obj = spawns(obj,timeStep)

            obj.model = MotionModel(timeStep);

            
        end
    end
end

