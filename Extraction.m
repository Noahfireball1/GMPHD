classdef Extraction    
    properties
        numTracks = [];
        weights = [];
        states = [];
        covariances = [];

        threshold = [];

        extractedWeights = [];
        extractedStates = [];
        extractedCovariances = [];
    end
    
    methods
        
        function extracting(obj)

            for track = 1:obj.numTracks

                if obj.weights(track) > obj.threshold
                    
                    obj.extractedWeights = [obj.extractedWeights obj.weights(track)];
                    obj.extractedStates = [obj.extractedStates obj.states(:,track)];
                    obj.extractedCovariances = cat(3,obj.extractedCovariances,obj.covariances(:,:,track));

                end

            end
        end
    end
end

