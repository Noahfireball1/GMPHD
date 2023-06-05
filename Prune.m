classdef Prune < handle
    %PRUNE rids of any track estimates below a certain weight threshold
    
    properties

        % User-Defined Properties
        threshold {mustBeNumeric,mustBePositive} = 0.1;

        % Set by Filter
        numTracks = [];
        weights = [];
        states = [];
        covariances = [];

        % Products of Methods
        prunedWeights = [];
        prunedStates = [];
        prunedCovariances = [];

    end
    
    methods
        function pruning(obj)

            obj.numTracks = length(obj.weights);

            for track = 1:obj.numTracks

                if obj.weights(track) > obj.threshold
                    obj.prunedWeights = [obj.prunedWeights obj.weights(track)];
                    obj.prunedStates = [obj.prunedStates obj.states(:,track)];
                    obj.prunedCovariances = cat(3,obj.prunedCovariances,obj.covariances(:,:,track));
                end

            end
        end

        function reset(obj)

            obj.prunedWeights = [];
            obj.prunedStates = [];
            obj.prunedCovariances = [];

        end
    end
end

