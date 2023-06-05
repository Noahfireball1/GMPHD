classdef Extraction < handle
    %EXTRACTION saves estimated tracks that exceed the user-defined threshold 
    properties

        % User-Defined Properties
        threshold {mustBeNumeric,mustBePositive} = 0.4;
        
        % Set by Filter
        numTracks = [];
        weights = [];
        states = [];
        covariances = [];

        % Products of Methods
        extractedWeights = [];
        extractedStates = [];
        extractedCovariances = [];
    end

    methods

        function extracting(obj)

            obj.numTracks = length(obj.weights);

            for track = 1:obj.numTracks

                if obj.weights(track) > obj.threshold

                    obj.extractedWeights = [obj.extractedWeights obj.weights(track)];
                    obj.extractedStates = [obj.extractedStates obj.states(:,track)];
                    obj.extractedCovariances = cat(3,obj.extractedCovariances,obj.covariances(:,:,track));

                end

            end
        end

        function reset(obj)

            obj.extractedWeights = [];
            obj.extractedStates = [];
            obj.extractedCovariances = [];

        end
    end
end

