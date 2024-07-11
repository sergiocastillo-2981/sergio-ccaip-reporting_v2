view: call_handled_interactions
{
  derived_table:
  {
    sql:

       select hd.*,th.agent_name,th.level1 team_company
       FROM
       (
          SELECT
              c.id AS call_id
              ,c.instance_id AS instance_id
              ,hd.id
              ,CASE WHEN c.fail_reason in ('eu_in_menu_abandoned','eu_abandoned') and hd.agent_id is null then 99999 else hd.agent_id END agent_id
              ,hd.transfer AS transfer
              ,CAST(hd.started_at AS timestamp)AS started_at
              ,CAST(hd.ended_at AS timestamp)AS ended_at
              ,hd.acw_duration AS acw_duration
              ,hd.bcw_duration AS bcw_duration
              ,hd.call_duration AS call_duration
              ,hd.hold_duration AS hold_duration
              ,hd.menu_path
            FROM
              @{PROJECT_NAME}.@{DATASET}.`t_calls` c
            JOIN
              UNNEST (c.handle_durations) AS hd
      ) hd LEFT JOIN @{PROJECT_NAME}.@{DATASET}.`v_teams_hierarchy` th
      on hd.agent_id = th.id and hd.instance_id = th.instance_id
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

  dimension: hd_interaction_id
  {
    description: "Unique ID for each interaction within the call"
    type: number
    primary_key: yes
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
    description: "Agent of the Handled Interaction"
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: hd_team_company
  {
    description: "Team Company of the Agent on the Handled Interaction"
    type: string
    sql: ${TABLE}.team_company ;;
  }

  dimension: hd_queue_name
  {
    description: "Queue of the Handled Interaction"
    type: string
    sql: ${TABLE}.menu_path ;;
  }

  dimension_group: hd_interaction_start
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
    #drill_fields: [call_detail*]
  }

  dimension_group: hd_interaction_end
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
    #drill_fields: [call_detail*]
  }

  dimension: acw_duration
  {
    description: "After Call Work Duration"
    type: number
    sql: ${TABLE}.acw_duration ;;
  }

  dimension: acw_duration_hms
  {
    description: "After Call Work Duration (in HH:MM:SS)"
    type: number
    sql: ${acw_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: bcw_duration
  {
    description: "Before Call Work Duration"
    type: number
    sql: ${TABLE}.bcw_duration ;;
  }

  dimension: bcw_duration_hms
  {
    description: "Before Call Work Duration (in HH:MM:SS)"
    type: number
    sql: ${bcw_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: call_duration
  {
    description: "Duration of the interaction"
    type: number
    sql: ${TABLE}.call_duration ;;
  }

  dimension: call_duration_hms
  {
    description: "Duration of the interaction (in HH:MM:SS)"
    type: number
    sql: ${call_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: hi_status
  {
    description: "Handled Interaction Status"
    label: "Status"
    type: string
    sql: CASE WHEN ${acw_duration}>0 THEN 'acw_ended' ELSE 'call_finished' END ;;
  }

  dimension: hold_duration
  {
    description: "Duration of the interaction"
    type: number
    sql: ${TABLE}.hold_duration ;;
  }

  ########################################################################################
  #####################################   MEASURES   #####################################
  ########################################################################################

  #measure: sum_hold_duration
  #{
  #  group_label: "Totals"
  #  type: sum
  #  sql: ${hold_duration} ;;
  #}

  #measure: avg_hold_time
  #{
  #  group_label: "Avg"
  #  type: number
  #  sql: (${sum_hold_duration} / ${call_queued_interactions.count})/86400.0   ;;
  #  value_format_name: HMS
  #}


}
