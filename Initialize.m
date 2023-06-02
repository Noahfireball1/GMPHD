classdef Initialize < handle
    %INITIALIZE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        initTime = 1;
        finalTime = 100;
        timeStep = 1;
        scenario = 'simple';
        model = [];
        state = [];
        numTargets = [];

    end

    methods
        function genTruth(obj)

            obj.model = MotionModel(obj.timeStep);

            switch lower(obj.scenario)
                case 'simple'
                    obj.simple();

                case 'ospa'
                    OSPA(parameters.motion_model.F,numTimestep);

                case 'random'
                    random(parameters.motion_model.F,numTimestep);

                otherwise
                    error('Incorrect scenario specified!')
            end

        end

        function simple(obj)

            timeArray = obj.initTime:obj.timeStep:obj.finalTime;
            numTimeSteps = numel(timeArray);
            obj.numTargets = zeros(numTimeSteps,1);

            %% Determinstic Starting Points
            % Track 1
            xStart(:,1) = [300; 2; 300; -12]; % [posX; velX; posY; velY]
            tBirth(1) = 1;  % [s] Track is born at the start of the simulation
            tDeath(1) = numTimeSteps+1; % [s] Track survives the entire length of the simulation

            % Track 2
            xStart(:,2) =  [-300; 12; -300; -2];
            tBirth(2) = 1;
            tDeath(2) = numTimeSteps+1;

            % Track 3
            xStart(:,3) = [445; -12; -530; -3];
            tBirth(3) = 69;
            tDeath(3) = numTimeSteps + 1;

            %% Determinstic Trajectories
            for target = 1:size(xStart,2)
                % Getting initial state for track defined above
                targetState = xStart(:,target);

                %Finding ending state of track
                targetStateFinal = min(tDeath(target),numTimeSteps);

                % Stepping through time and propogating track states
                for time = tBirth(target):targetStateFinal
                    % Propagated state [posX; velX; posY; velY]
                    targetState = obj.model.F*targetState;

                    % Sticking together propgated states
                    obj.state{time,1}(:,target) = targetState;

                    % Total number of existing tracks per timestep
                    obj.numTargets(time,:) = obj.numTargets(time) + 1;
                end
            end

        end

        function OSPA(obj)

        end

        function random(obj)


        end
    end
end

