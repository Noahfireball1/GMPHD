classdef Prune
    %PRUNE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numTracks = [];
        weights = [];
        states = [];
        covariances = [];

        threshold = [];

        prunedWeights = [];
        prunedStates = [];
        prunedCovariances = [];

    end
    
    methods
        function pruning(obj)

            for track = 1:obj.numTracks

                if obj.weights(track) > obj.threshold
                    obj.prunedWeights = [obj.prunedWeights obj.weights(track)];
                    obj.prunedStates = [obj.prunedStates obj.states(:,track)];
                    obj.prunedCovariances = cat(3,obj.prunedCovariances,obj.covariances(:,:,track));
                end

            end
        end
    end
end

