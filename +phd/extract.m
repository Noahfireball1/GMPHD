% [extractedWeight, extractedLabels, extractedMean, extractedCovariance,...
%     stateEstimateSet,trackLabelSet,timeSet,CN,unconfirmedLabels_k,model] = ...
%     explicitTrackEstimate(updatedWeight,updatedMean,updatedCovariance, ...
%     extractedWeight,extractedMean,extractedCovariance,extractedLabels, ...
%     labelClassification,maximumWeight,maximumWeightLabel,rn,cn,CN, ...
%     stateEstimateSet,trackLabelSet,timeSet,unconfirmedLabels_k1,unconfirmedLabels_k2,model,k)
%
%  explicitTrackEstimate uses posterior weights and labels to associate
%  components with 'confirmed' or 'unconfirmed' targets. Only confirmed
%  targets have their state calculated and saved into "stateEstimateSet"
%
% Inputs: 
%   updatedWeight - posterior weight of targets calculated during update
%   updatedMean - posterior mean/state of targets calculated during update
%   updatedCovariance - posterior covariance of targets calculated during update
%   extractedWeight - maximum weight of targets calculated during state extraction
%   extractedMean - mean/state of target with highest weight compared to the current measurement
%   extractedCovariance - covariance of target with highest weight compared to the current measurement
%   extractedLabels - label of target with highest weight compared to the current measurement
%   labelClassification - {'A','B','C'} based on the cases presented in the paper
%   maximumWeight - Maximum weight found in the "updatedWeight" variable 
%   maximumWeightLabel - Label of target where "maximumWeight" is found
%   rn - row number of maximum weight found in "updatedWeight" variable
%   cn - column number of maximum weight found in "updatedWeight" variable
%   CN - array of column numbers to be set to 0 after the loop runs
%   stateEstimateSet - extracted states of confirmed targets
%   trackLabelSet - labels of these confirmed targets and their extracted state
%   timeSet - time array when these confirmed targets were extracted
%   unconfirmedLabels_k1 - If a target is labeled 'unconfirmed', save the label. This is the array at the last time step 
%   unconfirmedLabels_k2 - This is the same unconfirmed label array, but two timesteps behind
%   model - struct containing weight thresholds used to sort the targets
%   k - current timestep
%
% Outputs:
%   extractedWeight - Updated maximum weight of targets calculated during state extraction
%   extractedLabels - updated label of target with highest weight compared to the current measurement
%   extractedMean - Updated mean/state of target with highest weight compared to the current measurement
%   extractedCovariance - Updated covariance of target with highest weight compared to the current measurement
%   stateEstimateSet - Updated extracted states of confirmed targets
%   trackLabelSet - Updated labels of these confirmed targets and their extracted state
%   timeSet - Updated time array when these confirmed targets were extracted 
%   CN - Updated array of column numbers to be set to 0 after the loop runs
%   unconfirmedLabels_k - current timestep of the labels attributing unconfirmed targets
%   model - Using the model struct to update the number of confirmed and unconfirmed targets
%
% Author(s): Noah Miller
% Last Updated: 12/15/2022
% Modified by Deanna Phillips - Changed some logic, uniform variable names
%   with other codes, and adjusted output

function [extraction_state_variables,updated_state_variables] = extract(extraction_inputs,state_variable_table)
%Parsing
motion_model=extraction_inputs.motion_model;
filter_parameters=extraction_inputs.filter_parameters;

%Precision limit due to floating point accuracy
precision_limit=1e-5;

%Creating update table - same as input with modifications to be made through processing
updated_state_variable_table=state_variable_table;

%Saving/perserving original copy of state_variable.weight to save original
%weights and not zero weights
original_state_variable_table=state_variable_table;

%Preallocation (for extraction output)
extraction_state_variables.weight=[];
extraction_state_variables.state=[];
extraction_state_variables.covariance=[];
extraction_state_variables.time=[];
extraction_counter=1; %count of number of elements - start at the first index
unconfirmed_label_counter=1; %count of number of elements - start at the first index

%As long as there are weights that are not zero
while sum(state_variable_table.weight(:, 2:end),'all') > 0

    %% Finding max weight (step 1)
    %Max weight in entire observation matrix
    max_weight=max(max(state_variable_table.weight(:,2:end)));

    if max_weight>=filter_parameters.weight_basic
        %Indices of max weight
        %state weight=max weight + some precision due to floating point number
        [max_weight_rows,max_weight_cols]=find(abs(state_variable_table.weight-max_weight)<precision_limit);

        %Initalize column numbers
        measurement_col_num=[];

        %% Matching tracks to observations with labels
        for ii=1:length(max_weight_label)

            %Input structure for tracks to labels
            track_2_label_inputs.filter_parameters=filter_parameters;
            track_2_label_inputs.max_weight_info.max_weight=max_weight;
            track_2_label_inputs.max_weight_info.max_weight_row=max_weight_rows(ii);
            track_2_label_inputs.max_weight_info.max_weight_col=max_weight_cols(ii);

            % comparing labels to tracks
            if label_index < label_values.V_unconfirmed
                %Case C - confirmed track
                [extract_variables,state_variable_table] = other.extract_confirmed_tracks(motion_model.R,motion_model.H,track_2_label_inputs,state_variable_table);

            elseif (label_index >= label_values.V_unconfirmed) && (label_index < label_values.V_new)
                %Case B - unconfirmed track
                [unconfirmed_labels,extract_variables,updated_state_variable_table]= other.extract_unconfirmed_tracks(track_2_label_inputs,state_variable_table,updated_state_variable_table,unconfirmed_labels_set);

                %Set new label max number
                if extract_variables.extraction_flag==true
                    label_values.r_max_confirmed=extract_variables.label;
                end

                %Save unconfirmed label
                if ~isempty(unconfirmed_labels) 
                unconfirmed_label_set(unconfirmed_label_counter)=unconfirmed_labels; %#ok<AGROW>  <--suppresses warning message about growing loop
                unconfirmed_label_counter=unconfirmed_label_counter+1;
                end

            elseif label_index >= label_values.V_new
                %Case A - new track
                [extract_variables,updated_state_variable_table] = other.extract_new_tracks(track_2_label_inputs,state_variable_table,updated_state_variable_table);
                label_values=extract_variables.label_values;
            end

            %Zeroing out tracks that have labels with the same max weight
            state_variable_table.weight(label_index_rows,:)=0;

            %Adding to list of measurement column number for this iteration
            if extract_variables.extraction_flag==true
                measurement_col_num=[measurement_col_num,extract_variables.zero_col_num]; %#ok<AGROW>  <--suppresses warning message about growing loop
            end

            %% Extract states (output)
            if extract_variables.extraction_flag==true
                %Number of tracks to extract
                num_extractions=length(extract_variables.label);

                for jj=1:num_extractions
                    %State to extract based on row and column numbers from specific cases
                    extraction_measurement=state_variable_table.state{extract_variables.row_number(jj),extract_variables.col_number(jj)};

                    %Extraction set of state, label and time
                    extraction_state_variables.weight(extraction_counter)=original_state_variable_table.weight(extract_variables.row_number(jj),extract_variables.col_number(jj));
                    extraction_state_variables.state(:,extraction_counter)=motion_model.H*extraction_measurement;
                    extraction_state_variables.covariance(:,:,extraction_counter)=state_variable_table.covariance{extract_variables.row_number(jj),extract_variables.col_number(jj)};
                    extraction_state_variables.label(extraction_counter)=extract_variables.label(jj);
                    extraction_state_variables.time(extraction_counter)=extraction_inputs.time_value;

                    %Increasing counter by one index
                    extraction_counter=extraction_counter+1;
                end
            end

        end

        %% Step 3
        %Matched the max weights to tracks with the same label so zero out observation
        state_variable_table.weight(:,measurement_col_num)=0;
    else
        %Max weight didn't reach threshold so all other weights are less and are ignored
        state_variable_table.weight=0;
    end

end

%% State Variables Output (step 4) - Shifting from matrix into single vector based on new established tracks
%Total number of elements (row x column)
number_elements=numel(updated_state_variable_table.weight);

%Preallocation
updated_state_variables.weight=zeros(1,number_elements);
updated_state_variables.state=zeros(motion_model.x_dim,number_elements);
updated_state_variables.covariance=zeros(motion_model.x_dim,motion_model.x_dim,number_elements);

%Matrix into vector
for ii=1:number_elements
    updated_state_variables.weight(ii)=updated_state_variable_table.weight(ii);
    updated_state_variables.state(:,ii)=updated_state_variable_table.state{ii};
    updated_state_variables.covariance(:,:,ii)=updated_state_variable_table.covariance{ii};
end

end