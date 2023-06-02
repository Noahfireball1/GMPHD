classdef Observations < handle

    properties
        truth = [];
        lambda = 1;
        clutterXRange = [-1000 1000];
        clutterYRange = [-1000 1000];
        clutter = [];

        measVar = 3;
        measurements = [];

    end

    methods

        function obj = getMeasurements(obj)

            obj.genClutter();

            obj.genMeasurements();

            obj.measurements = [obj.clutter obj.measurements];

        end

        function genClutter(obj)

            clutterAmount = poissrnd(obj.lambda);

            obj.clutter(1,:) = randi(obj.clutterXRange,[1 clutterAmount]);
            obj.clutter(2,:) = randi(obj.clutterYRange,[1 clutterAmount]);

        end

        function genMeasurements(obj)

            numTrueTracks = size(obj.truth,2);

            obj.measurements(1,:) = obj.truth(1,:) + obj.measVar*randn([1 numTrueTracks]);
            obj.measurements(2,:) = obj.truth(3,:) + obj.measVar*randn([1 numTrueTracks]);

        end

        function clutterIntensity = clutterIntensity(obj,meas)

            intensity = obj.normpdf2D(obj.clutterXRange,obj.clutterYRange,meas);
            clutterIntensity = obj.lambda*intensity;

        end

        function intensity = normpdf2D(~,xRange,yRange,mean)

            if(mean(1) < xRange(1))
                intensity = 0;

            elseif(mean(1) > xRange(2))
                intensity = 0;

            elseif (mean(2) < yRange(1))
                intensity = 0;

            elseif(mean(2) > yRange(2))
                intensity = 0;

            else
                intensity = 1/((xRange(2) - xRange(1))*(yRange(2) - yRange(1)));
            end

        end

        function reset(obj)

            obj.measurements = [];
            obj.clutter = [];
        end
    end
end

