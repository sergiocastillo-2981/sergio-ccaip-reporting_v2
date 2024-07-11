view: call_interactions {

  derived_table:
  {
    sql: select * from @{PROJECT_NAME}.@{DATASET}.`v_call_interactions` ci
      ;;
  }

  dimension: interaction_id
  {
    type: number
    sql: ${TABLE}.interaction_id ;;
    primary_key: yes
  }

  dimension: agent_id {
    type: number
    sql: ${TABLE}.agent_id ;;
  }

  dimension: call_id {
    type: number
    sql: ${TABLE}.call_id ;;
  }

  #dimension: brand_name
  #{
  #  type: string
  #  sql: ${TABLE}.brand_name ;;
  #}

  dimension: interaction_status
  {
    description: "Indicates if the Queue Interaction was answered,failed,deflected or abandoned"
    type: string
    sql: ${TABLE}.qi_status ;;
  }

  dimension_group: hi_ended
  {
    description: "Date Time when the Handled Interaction ended"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.hi_ended_at ;;
  }
  dimension_group: hi_started
  {
    description: "Date Time when the Handled Interaction started"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.hi_started_at ;;
  }
  dimension: hi_transfer
  {
    description: "Indicates if the Handled interaction was handled"
    type: yesno
    sql: ${TABLE}.hi_transfer ;;
  }

  dimension: instance_id {
    type: number
    sql: ${TABLE}.q_instance_id ;;
  }
  dimension: menu_path {
    label: "Queue Name"
    type: string
    sql: ${TABLE}.menu_path ;;
  }
  dimension: menu_path_id {
    label: "Queue ID"
    type: number
    sql: ${TABLE}.menu_path_id ;;
  }
  dimension_group: qi_ended
  {
    description: "Date Time when the Queue Interaction ended"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.qi_ended_at ;;
  }
  dimension_group: qi_started
  {
    description: "Date Time when the Handled Interaction started"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.qi_started_at ;;
  }

  dimension: queue_duration {
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: abandon_time
  {
    description: "Sum of Queue Time for all the interactions that were abandoned"
    type: number
    #sql: CASE WHEN ${call_details.fail_reason} in ('eu_in_menu_abandoned','eu_abandoned') then ${queue_duration} else 0 END ;;
    sql: CASE WHEN ${interaction_status} in ('abandoned') then ${queue_duration} else 0 END ;;
  }

  dimension: answer_time
  {
    description: "Queue time for calls that were handled"
    type: number
    #sql: CASE WHEN ${call_details.status} ='finished' AND ${call_details.fail_reason} ='nothing' then ${queue_duration} else 0 END ;;
    sql: CASE WHEN ${interaction_status} ='answered' then ${queue_duration} else 0 END ;;
  }

  dimension: hold_duration
  {
    type: number
    sql: ${TABLE}.hold_duration ;;
  }

  dimension: acw_duration
  {
    type: number
    sql: ${TABLE}.acw_duration ;;
  }

  dimension: bcw_duration
  {
    description: "Before Call Work Duration"
    type: number
    sql: ${TABLE}.bcw_duration ;;
  }

  dimension: handle_duration
  {
    description: "BCW + Talk Duration + ACW"
    type: number
    sql: ${TABLE}.bcw_duration +${TABLE}.call_duration + ${TABLE}.acw_duration ;;
  }

  dimension: talk_time
  {
    description: "Time spent talking by Agent (Call Duration)"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.call_duration;;
  }

  dimension: service_level_event {
    type: string
    sql: ${TABLE}.service_level_event ;;
  }

  dimension: in_sla
  {
    description: "Queue Interactions where queue time is less than the SLA threshold"
    type: number
    #sql: ${TABLE}.in_sla ;;
    sql: CASE WHEN ${TABLE}.service_level_event = 'in_sla' then 1 else 0 END;;
  }

  dimension: not_in_sla
  {
    description: "Queue Interactions where queue time is over than the SLA threshold"
    type: number
    #sql: ${TABLE}.in_sla ;;
    sql: CASE WHEN ${TABLE}.service_level_event = 'not_in_sla' then 1 else 0 END;;
  }

  dimension: qi_transfer
  {
    description: "Indicates if the Handled interaction came from a transfer"
    type: number
    sql: CASE WHEN ${TABLE}.qi_transfer is true then 1 else 0 END;;
  }

  ########################################################################################
  #####################################   MEASURES   #####################################
  ########################################################################################

  measure: count {
    group_label: "Totals"
    description: "Count of unique Queued Interactions"
    label: "Queued Interactions"
    type: count
  }

  measure: interactions_handled
  {
    group_label: "Totals"
    label: "Total Handled"
    description: "The sum of Interactions where status= answered or deflected"
    type: count
    filters: [interaction_status: "answered,deflected"]
  }

  measure: total_interactions_abandoned
  {
    group_label: "Totals"
    label: "Total Abandoned"
    description: "Total Interactions abandoned (status=abandoned)"
    type: count
    filters: [interaction_status: "abandoned"]
  }

  measure: total_interactions_short_abandoned
  {
    group_label: "Totals"
    label: "Total Short Abandoned"
    description: "Number of Interactions that were abandoned within 10 seconds by the consumer while waiting in queue"
    type: count
    filters: [interaction_status: "abandoned", queue_duration: "<=10"]
  }

  measure: total_interactions_transfered
  {
    group_label: "Totals"
    description: "Total Interactions transfered"
    type: sum
    sql: ${qi_transfer} ;;
  }

  measure: total_aband_time
  {
    description: "Sum of Queue Time for all the calls that were abandoned"
    group_label: "Totals"
    type: sum
    sql: ${abandon_time} ;;
  }

  measure: total_answer_time
  {
    description: "Total Queue time for calls that were handled"
    group_label: "Totals"
    type: sum
    sql: ${answer_time} ;;
  }

  measure: total_queue_time
  {
    description: "Queue time for all Interactions in the selection"
    group_label: "Totals"
    type: sum
    sql: ${queue_duration} ;;
  }

  measure: avg_queue_time_hms
  {
    description: "Avg Queue time for all Interactions in the selection"
    group_label: "Avg"
    type: average
    sql: ${queue_duration}/86400.0 ;;
    value_format_name: HMS
  }


  measure: avg_aband_time
  {
    #this needs to be calculated at interaction since aband time is queue time of the interaction when call in status abandoned
    group_label: "Avg"
    description: "Total Abandon Time / Total Abandoned"
    type: number
    #sql: CASE WHEN ${call_details.total_abandoned} = 0 then 0 ELSE (${total_aband_time} / ${call_details.total_abandoned})/86400.0 END;;
    sql: CASE WHEN ${total_interactions_abandoned} = 0 then 0 ELSE (${total_aband_time} / ${total_interactions_abandoned})/86400.0 END;;
    value_format_name: HMS
  }

  measure: perc_abandoned
  {
    group_label: "Percent"
    label: "Abandoned %"
    description: "Calls Abandoned / Queue Interactions"
    type: number
    sql:  ${total_interactions_abandoned}/${count};;
    value_format_name: percent_2
  }

  measure: perc_handled
  {
    group_label: "Percent"
    label: "Handled %"
    description: "Interactions Handled / Queued Interactions"
    type: number
    sql: ${interactions_handled} / ${count} ;;
    value_format_name: percent_2
  }

  measure: perc_transfered
  {
    group_label: "Percent"
    label: "Transfer %"
    description: "Interactions Transfered / Queued Interactions"
    type: number
    sql: ${total_interactions_transfered} / ${count} ;;
    value_format_name: percent_2
  }

  measure: total_hold_time
  {
    group_label: "Totals"
    type: sum
    sql: ${hold_duration} ;;
  }

  measure: total_handle_time
  {
    group_label: "Totals"
    type: sum
    sql: ${handle_duration};;
  }

  measure: avg_hold_time_hms
  {
    group_label: "Avg"
    description: "Hold Duration / Queue Interactions"
    type: number
    sql: (${total_hold_time} / ${count})/86400.0   ;;
    value_format_name: HMS
  }

  measure: avg_speed_answer_hms
  {
    group_label: "Avg"
    label: "ASA"
    description: "Avg Speed of Answer Queue Time / Queued Interactions in  (HH:MM:SS)"
    type: number
    sql: (${total_answer_time} / ${count})/86400.0 ;;
    value_format_name: HMS
  }

  measure: count_in_sla
  {
    group_label: "Totals"
    label: "Count In SLA"
    description: "Count of contacts where queue time is less than the SLA threshold"
    type: sum
    sql: ${in_sla} ;;
  }
  measure: count_out_sla
  {
    group_label: "Totals"
    label: "Count Out SLA"
    description: "Count of contacts where queue time is equal to or greater than the SLA threshold."
    type: sum
    sql: ${not_in_sla} ;;
  }

  measure: perc_in_sla
  {
    group_label: "Percent"
    label: "SLA %"
    description: "Count of Contacts In SLA /(Count of Contacts  In SLA + count of Contacts Out SLA"
    type: number
    sql: case when (${count_in_sla} + ${count_out_sla}) = 0 then 0 else ${count_in_sla} / (${count_in_sla} + ${count_out_sla}) end;;
    value_format_name: percent_2
  }

  measure: sum_wrapup_duration
  {
    group_label: "Totals"
    label: "Total Wrapup Time"
    type: sum
    sql: ${acw_duration} ;;
  }

  measure: avg_wrapup_time_hms
  {
    group_label: "Avg"
    description: "Wrapup Duration / Queue Interactions"
    type: average
    sql: ${acw_duration} /86400.0 ;;
    value_format_name: HMS
    #sql: (${sum_wrapup_duration} / ${count})/86400.0   ;;
    #value_format_name: HMS
  }

  measure: avg_handle_time_hms
  {
    #using avg(handle) or handle/queue interactios shows same result
    group_label: "Avg"
    description: "Handle Duration / Queue Interactions"
    type: average
    sql:  ${handle_duration}/86400.0;;
    value_format_name: HMS
  }

  measure: avg_handle_time_test
  {
    #using avg(handle) or handle/queue interactios shows same result
    group_label: "Avg"
    description: "Handle Duration / Queue Interactions"
    type: number
    #sql:  ${handle_duration}/86400.0;;
     sql: (${total_handle_time} / ${count})/86400.0 ;;
    value_format_name: HMS
  }


  measure: avg_talk_time_hms
  {
    description: "Average Time spent talking (Handle call duration)"
    group_label: "Avg"
    type: average
    sql: ${talk_time} /86400.0;;
    value_format_name: HMS
  }

}
