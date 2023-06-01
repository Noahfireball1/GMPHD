classdef Observations
    
    properties
        truth = [];
        lambda = 2;
        clutterXRange = [-1000 1000];
        clutterYRange = [-1000 1000];
        clutter = [];

        measVar = 10;
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

            obj.clutter(:,1) = randi(obj.clutterXRange,[clutterAmount 1]);
            obj.clutter(:,2) = randi(obj.clutterYRange,[clutterAmount 1]);

        end

        function genMeasurements(obj)

            numTrueTracks = size(obj.truth,2);

            obj.measurements(:,1) = obj.truth(:,1) + obj.measVar*randn([numTrueTracks 1]);
            obj.measurements(:,1) = obj.truth(:,2) + obj.measVar*randn([numTrueTracks 1]);

        end

        function clutterIntensity = clutterIntensity(obj,meas)

            clutterIntensity = obj.lambda*mvnpdf(obj.clutterXRange,obj.clutterYRange,meas);

        end
    end
end

