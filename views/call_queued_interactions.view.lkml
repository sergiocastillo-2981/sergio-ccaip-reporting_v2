view: call_queued_interactions
{
  derived_table:
  {
    sql:
      select  qd.call_id
              ,qd.instance_id
              ,qd.started_at
              ,qd.ended_at
              ,qd.status
              ,qd.id
              ,qd.fail_reason
              ,qd.agent_id
              ,qd.menu_path
              ,qd.service_level_event
              ,qd.lang
              ,qd.queue_duration
              ,qd.transfer
              ,qd.interaction_status
      ,th.agent_name,th.level1 team_company
      from
      (
            SELECT
              c.id call_id
              ,c.instance_id
              ,CAST(qd.started_at AS timestamp)AS started_at
              ,CAST(qd.ended_at AS timestamp)AS ended_at
              ,c.status
              ,qd.id
              ,c.fail_reason
              ,CASE WHEN c.fail_reason in ('eu_in_menu_abandoned','eu_abandoned') and qd.agent_id is null then 99999 else qd.agent_id END agent_id
              ,qd.menu_path
              ,qd.service_level_event
              ,qd.lang
              ,qd.queue_duration
              ,qd.transfer
              ,CASE WHEN qd.transfer_id is null then
                      CASE  WHEN c.fail_reason = 'nothing' and c.deflection ='no_deflection' then 'answered'
                            WHEN c.fail_reason = 'nothing' and c.deflection !='no_deflection' then 'deflected'
                            WHEN c.fail_reason in ('eu_abandoned','eu_in_menu_abandoned') then 'abandoned'
                            ELSE 'failed'
                      END
                    WHEN qd.transfer_id is not null and tr.status = 'transferred' then 'answered'
                    ELSE tr.status
               END interaction_status
            FROM
              @{PROJECT_NAME}.@{DATASET}.`t_calls` c
            JOIN  UNNEST (c.queue_durations) AS qd
            LEFT JOIN UNNEST (c.transfers) tr on qd.transfer_id = tr.id
            WHERE qd.menu_path is not null --Excluding interactions with Queue in null, just like OOB
      ) qd left join @{PROJECT_NAME}.@{DATASET}.`v_teams_hierarchy` th
            on qd.agent_id = th.id and qd.instance_id = th.instance_id
            --Left join is required to show interactions where there was no agent.
       ;;
  }

####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################

  dimension: call_id
  {
    description: "Unique ID for each call"
    hidden: yes
    type: number
    value_format: "#######"
    sql: ${TABLE}.call_id ;;
  }

  dimension: instance_id
  {
    type: number
    hidden: yes
    sql: ${TABLE}.instance_id ;;
  }

  dimension: qd_interaction_id
  {
    description: "Unique ID for each interaction within the call"
    primary_key: yes
    type: number
    value_format: "#######"
    sql: ${TABLE}.id ;;
  }

  dimension: agent_id
  {
    type: string
    sql: ${TABLE}.agent_id ;;
  }

  dimension: agent_name
  {
    description: "Agent of the Queued Interaction"
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: qd_queue_name
  {
    description: "Queue of the Queued Interaction"
    type: string
    sql: ${TABLE}.menu_path ;;
  }

  dimension: qd_team_company
  {
    description: "Team Company of the Agent on the Queued Interaction"
    type: string
    sql: ${TABLE}.team_company ;;
  }

  dimension: transferred
  {
    description: "Indicates if the interaction was created due to a Transfer"
    type: string
    sql: ${TABLE}.transfer ;;
  }

  dimension: fail_reason
  {
    type: string
    sql: ${TABLE}.fail_reason ;;
  }

  dimension: status
  {
    #this field is required to calculate the Handled Calls
    #we need it at the interation level to combine it with
    #the queue time
    description: "Overal Status of the call"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: interaction_status
  {
    description: "Status of the interaction"
    type: string
    sql: ${TABLE}.interaction_status ;;
  }

  dimension: language
  {
    description: "Language of the Interaction"
    type: string
    sql: ${TABLE}.lang ;;
  }

  dimension_group: qd_interaction_start
  {
    type: time
    timeframes: [
      raw,
      time,
      date,
      hour_of_day,
      day_of_week,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.started_at ;;
  }
  dimension_group: qd_interaction_end
  {
    type: time
    timeframes: [
      raw,
      time,
      date,
      hour_of_day,
      day_of_week,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.ended_at ;;
  }

  dimension: queue_duration
  {
    description: "Queue Time of the Interactions (in seconds)"
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: abandon_time
  {
    description: "Sum of Queue Time for all the calls that were abandoned"
    type: number
    sql: CASE WHEN ${fail_reason} in ('eu_in_menu_abandoned','eu_abandoned') then ${queue_duration} else 0 END ;;
  }

  dimension: queue_duration_hms
  {
    description: "Queue Time of the Interaction (in HH:MM:SS)"
    type: number
    sql: ${queue_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: service_level_event
  {
    description: "Service Level Event of the Interaction"
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

  ########################################################################################
  #####################################   MEASURES   #####################################
  ########################################################################################

  measure: count
  {
    group_label: "Totals"
    description: "Count of unique Queued Interactions"
    label: "Queued Interactions"
    type: count
  }

  measure: perc_abandoned
  {
    group_label: "Percent"
    label: "Abandoned %"
    description: "Calls Abandoned vs Queue Interactions"
    type: number
    sql:  ${call_details.total_abandoned}/${count};;
    value_format_name: percent_2
  }

  measure: count_handled
  {
    #this is used to calculate avg handle time
    group_label: "Totals"
    label: "Total Handled"
    description: "The sum of Calls where status=finished and fail_reason=nothing"
    type: count
    filters: [status: "finished" ,fail_reason: "nothing"]
  }

  measure: total_queue_time
  {
    group_label: "Totals"
    type: sum
    sql: ${queue_duration} ;;
  }

  measure: total_aband_time
  {
    group_label: "Totals"
    type: sum
    sql: ${abandon_time} ;;
  }

  measure: avg_aband_time
  {
    #this needs to be calculated at interaction since aband time is queue time of the interaction
    group_label: "Avg"
    description: "Total Abandon Time / Total Abandoned"
    type: number
    sql: CASE WHEN ${call_details.total_abandoned} = 0 then 0 ELSE (${total_aband_time} / ${call_details.total_abandoned})/86400.0 END;;
    value_format_name: HMS
  }

  measure: avg_queue_duration_hhmmss
  {
    group_label: "Avg"
    label: "Avg Speed of Answer (Avg Queue Time) HH:MM:SS"
    type: average
    sql: ${queue_duration_hms} ;;
    value_format_name: HMS
  }

  measure: avg_speed_answer_hms
  {
    group_label: "Avg"
    label: "Avg Speed of Answer (HH:MM:SS)"
    type: number
    sql: (${total_queue_time} / ${count})/86400.0 ;;
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

  measure: avg_wrapup_time_hms
  {
    #need to use Wrapup here instead of call level or makes problems with call details on some other explores
    group_label: "Avg"
    description: "Wrapup Duration / Queue Interactions"
    type: number
    sql: (${call_details.sum_wrapup_duration} / ${count})/86400.0   ;;
    value_format_name: HMS
  }

  measure: avg_handle_time
  {
    group_label: "Avg"
    type: number
    sql: (${call_details.total_handle_time} / ${count_handled})/86400.0 ;;
    value_format_name: HMS
  }

  measure: avg_hold_time_hms
  {
    group_label: "Avg"
    description: "Hold Duration / Queue Interactions"
    type: number
    sql: (${call_details.sum_hold_duration} / ${count})/86400.0   ;;
    value_format_name: HMS
  }


}
