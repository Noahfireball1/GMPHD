

function [extract_variables,state_variable_table]=extract_confirmed_tracks(motion_model_R,motion_model_H,extraction_inputs,state_variable_table) %Case C

%Helpful numbers
num_columns=size(state_variable_table.weight,2);
distance_measurement_error=norm(sqrt(diag(motion_model_R)));

%Parsing variables (only for ease of access)
max_weight_value=extraction_inputs.max_weight_info.max_weight;
max_weight_row=extraction_inputs.max_weight_info.max_weight_row;
max_weight_col=extraction_inputs.max_weight_info.max_weight_col;
label=extraction_inputs.max_weight_info.label;
label_row_numbers=extraction_inputs.max_weight_info.label_row;
filter_parameters=extraction_inputs.filter_parameters;

%% State to extract - biggest weight within measurement distance
if (max_weight_value<filter_parameters.weight_medium)
    %State with max weight
    extracted_state=state_variable_table.state{max_weight_row,max_weight_col};

    %Finding max weight (of tracks assuming no detections [col 1]) of the label(s) of interest
    [~,weight_index]=max(state_variable_table.weight(label_row_numbers,1));

    %Label row number of maximum weight
    label_row_number_index=label_row_numbers(weight_index);

    %State with same label of max weight assuming no detection
    state_no_detection=state_variable_table.state{label_row_number_index,1};

    %Finding distance between two different measurements
    distance_medium = other.state_distance(extracted_state,state_no_detection,motion_model_H);

    if distance_medium>distance_measurement_error
        %Track distance is bigger than measurement error distance (no covariance) so no detection
        extract_variables.row_number=label_row_number_index;
        extract_variables.col_number=1;
    else
        %Extract biggest weight or strongest match
        extract_variables.row_number=max_weight_row;
        extract_variables.col_number=max_weight_col;
    end
else
    %Extract biggest weight or strongest match
    extract_variables.row_number=max_weight_row;
    extract_variables.col_number=max_weight_col;
end

%% States variables to extract
%Extract tracks (row and column decided above)
extract_variables.extraction_flag=true;
extract_variables.label=label;

%Add to column numbers
extract_variables.zero_col_num=max_weight_col;

%% Modify weights of output state variables tables
%Outside the effective region (composed from both weights and distances), weight decreases to shield against interference

%Measurement from extracted state
extracted_state=state_variable_table.state{extract_variables.row_number,extract_variables.col_number};

for jj=2:num_columns %skipping no detection measurement column
    for ii=1:length(label_row_numbers) %row numbers of identical labels with same max weight
        % Finding distance from each extracted measurement to each measurement/track distance
        state_ij=state_variable_table.state{ii,jj};
        distance_ij = other.state_distance(extracted_state,state_ij,motion_model_H); %Distance between states

        % Distance thresholds (distance booleans)
        distance_boolean_1= distance_ij > 2*distance_measurement_error;
        distance_boolean_2= distance_ij > 3*distance_measurement_error;
        distance_boolean_3= distance_ij > 4*distance_measurement_error;
        distance_boolean_4= distance_ij > 5*distance_measurement_error;

        % Weight thresholds (weight booleans)
        weight_boolean_1 = max_weight_value>=filter_parameters.weight_extract;
        weight_boolean_2 = (max_weight_value<filter_parameters.weight_extract) && (max_weight_value>=filter_parameters.weight_large);
        weight_boolean_3 = (max_weight_value<filter_parameters.weight_large) && (max_weight_value>=filter_parameters.weight_medium);
        weight_boolean_4 = max_weight_value<filter_parameters.weight_medium;

        %Effective region 1 (boolean) - shortest distance, largest weight
        eff_1_boolean= distance_boolean_1 && weight_boolean_1;

        %Effective region 2 (boolean) - longer distance, smaller weight
        eff_2_boolean= distance_boolean_2 && weight_boolean_2;

        %Effective region 3 (boolean) - longer distance, smaller weight
        eff_3_boolean= distance_boolean_3 && weight_boolean_3;

        %Effective region 4 (boolean) - longest distance, smallest weight
        eff_4_boolean= distance_boolean_4 && weight_boolean_4;

        %If state/measurement falls in one of effective regions
        if eff_1_boolean || eff_2_boolean || eff_3_boolean || eff_4_boolean
            %Decrease weight
            state_variable_table.weight(ii,jj)=filter_parameters.weight_multiplier*max_weight_value;
        end

    end %end ii loop
end %end jj loop



end