classdef Birth < handle
    %BIRTH creates randomized estimates between given weights, ranges, and covariances

    properties

        % User-Defined Properties
        numBirths        {mustBeNumeric,mustBePositive,mustBeInteger} = 100;
        staticWeight     {mustBeNumeric,mustBePositive}               = 0.01;
        staticStateRange {mustBeVector,mustBeNumeric}                 = [-1000 1000 -50 50];
        staticCovariance {mustBeNumeric}                              = diag([4 1 4 1]);

        % Products of Methods
        birthWeights = [];
        birthStates = [];
        birthCovariances = [];

    end

    methods
        function predictBirths(obj)

            for birth = 1:obj.numBirths

                obj.birthWeights(birth) = obj.staticWeight;

                pos = randi([obj.staticStateRange(1:2)],[2 1]);
                vel = randi([obj.staticStateRange(3:4)],[2 1]);

                obj.birthStates(:,birth) = [pos(1) vel(1) pos(2) vel(2)];

                obj.birthCovariances(:,:,birth) = obj.staticCovariance;

            end

        end
    end
end

