

function [unconfirmed_label,extract_variables,updated_state_variable_table]=extract_unconfirmed_tracks(extraction_inputs,state_variable_table,updated_state_variable_table,unconfirmed_track_set) %Case B

%Need updated_state_variable_table for output - modify input for the output

%Parsing variables (only for ease of access)
max_weight_value=extraction_inputs.max_weight_info.max_weight;
max_weight_row=extraction_inputs.max_weight_info.max_weight_row;
max_weight_col=extraction_inputs.max_weight_info.max_weight_col;
label=extraction_inputs.max_weight_info.label;
label_row_numbers=extraction_inputs.max_weight_info.label_row;
filter_parameters=extraction_inputs.filter_parameters;
label_values=extraction_inputs.label_values;

%Setting up variables
unconfirmed_label=[]; %Empty label set
extract_variables.extraction_flag=false; %Default is to not extract unless conditions are met

%Determine if the weight is large enough to change from unconfirmed to confirmed
boolean_1 = (max_weight_value>=filter_parameters.weight_large); %true or false

%Determine if weight is too small
boolean_2 = (max_weight_value>=filter_parameters.weight_medium) && (max_weight_value<filter_parameters.weight_large); %true or false

%Determine if label is unconfirmed for the previous two timesteps
bool_3_idx = ismember(label,unconfirmed_track_set{1}); %First unconfirmed set
boolean_3 = any(bool_3_idx); %if any of the index is nonzero or true
bool_4_idx = ismember(label,unconfirmed_track_set{2}); %Second unconfirmed set
boolean_4 = any(bool_4_idx); %if any of the index is nonzero or true

%% If state and label fall within range, extract and update state variable table
if boolean_1 || (boolean_2 && boolean_3 && boolean_4)
    %Set new label
    new_label=label_values.r_max_confirmed+1;

    %Set extraction variables
    extract_variables.extraction_flag=true;
    extract_variables.row_number=max_weight_row;
    extract_variables.col_number=max_weight_col;
    extract_variables.label=new_label;
    extract_variables.zero_col_num=max_weight_col;

    %Modify update state variable table to establish new confirmed tracks
    updated_state_variable_table.weight(label_row_numbers,:)=0;
    updated_state_variable_table.weight(label_row_numbers,max_weight_col)=state_variable_table.weight(label_row_numbers,max_weight_col);
    updated_state_variable_table.label(label_row_numbers,:)=new_label;

else %% Keep as a unconfirmed track
    unconfirmed_label=label;
end

end