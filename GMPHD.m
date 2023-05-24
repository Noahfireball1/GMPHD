classdef GMPHD
    %GMPHD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Initialization
        Predict
        Update
        Observations
        Prune
        Merge
        Extraction
        Estimates
    end
    
    methods
        function obj = GMPHD()
            % GMPHD creates an instance of this class

            % Step 1: Initialize
            obj.Initialization = Initialize();

            % Step 2: Predict
            obj.Predict = Predict();

            % Step 3a: Observations
            obj.Observations = Observations();

            % Step 3b: Updating
            obj.Update = Update();

            % Step 4: Pruning
            obj.Prune = Prune();

            % Step 5: Merging
            obj.Merge = Merge();

            % Step 6a: Extraction
            obj.Extraction = Extraction();

            % Step 6b: Estimates
            obj.Estimates = Estimates();
            
        end
        
    end
end

