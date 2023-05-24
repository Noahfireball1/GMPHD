classdef Birth
    %BIRTH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numBirths = [];
        weights = [];
        states = [];
        covariances = [];

        staticWeight = [];
        stateRange = [];
        staticCovariance = [];
    end
    
    methods        
        function predictBirths(obj)

            for birth =  1:obj.numBirths
               
                obj.weights(birth) = obj.staticWeight;

                pos = randi([obj.stateRange(1:2)],[2 1]);
                vel = randi([obj.stateRange(3:4)],[2 1]);

                obj.states(:,birth) = [pos(1) vel(1) pos(2) vel(2)];

                obj.covariances(:,:,birth) = obj.staticCovariance;

            end

        end
    end
end

