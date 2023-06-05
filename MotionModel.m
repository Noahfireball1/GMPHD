classdef MotionModel

    properties
        F = [];
        u = 0;
        G = 0;
        varQ = 25;
        Q = [];
        varR = 100;
        R = [];
        H = [];
        numStates = 4;
        numMeas = 2;
    end

    methods
        function obj = MotionModel(dt)

            obj.F = [1 dt 0 0;
                0 1 0 0 ;
                0 0 1 dt;
                0 0 0 1];

            q1 = [(dt^4) / 4, (dt^3) / 2; ...
                (dt^3) / 2, dt^2];

            obj.Q = obj.varQ.*[q1,zeros(2);
                zeros(2),q1];

            obj.R = obj.varR.*eye(2);

            obj.H = [1 0 0 0; 0 0 1 0];

        end
    end
end