classdef Birth < handle
    %BIRTH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numBirths = 100;
        weights = [];
        states = [];
        covariances = [];

        staticWeight = 0.01;
        stateRange = [-1000 1000 -50 50];
        staticCovariance = diag([4 4 4 4]);
    end
    
    methods        
        function predictBirths(obj)

            for birth = 1:obj.numBirths
               
                obj.weights(birth) = obj.staticWeight;

                pos = randi([obj.stateRange(1:2)],[2 1]);
                vel = randi([obj.stateRange(3:4)],[2 1]);

                obj.states(:,birth) = [pos(1) vel(1) pos(2) vel(2)];

                obj.covariances(:,:,birth) = obj.staticCovariance;

            end

        end
    end
end

