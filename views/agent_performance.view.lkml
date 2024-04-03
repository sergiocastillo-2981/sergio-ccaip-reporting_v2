view: agent_performance
{
  derived_table:
  {
    sql:
       select hd.call_id,hd.instance_id
      ,hd.interaction_agent_id
      ,concat(a.first_name,' ',a.last_name)interaction_agent_name
      ,ao.agent_order
      ,case when hd.handled_call_agent_id = hd.interaction_agent_id then 1 else 0 end agent_handled
      ,hd.acw_duration,hd.bcw_duration,call_duration,hold_duration
      ,hd.call_type
      --,case when tp.from_agent_id is not null then true else false end transfer_placed
      --,case when tr.to_agent_id is not null then true else false end transfer_received
      ,case when tp.from_agent_id is not null then 1 else 0 end transfer_placed
      ,case when tr.to_agent_id is not null then 1 else 0 end transfer_received
      from
      (
        --Call and Handle Duration Info
        select c.id call_id,c.instance_id
        ,c.agent_info.id handled_call_agent_id
        ,hd.agent_id interaction_agent_id
        ,c.call_type
        ,sum(hd.acw_duration)acw_duration
        ,sum(hd.bcw_duration)bcw_duration
        ,sum(hd.call_duration)call_duration
        ,sum(hd.hold_duration)hold_duration
        FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
        left JOIN UNNEST (c.handle_durations) AS hd
        GROUP BY c.id,c.instance_id,c.agent_info.id,hd.agent_id,c.call_type
      )hd
      left join
      (
        --Transfers Placed
        select c.id call_id,c.instance_id
        ,tr.from_agent.id from_agent_id
        FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
        left JOIN UNNEST (c.transfers) AS tr
      )tp on hd.call_id = tp.call_id and hd.instance_id = tp.instance_id and hd.interaction_agent_id = tp.from_agent_id
      left join
      (
        --Transfers Received
        select c.id call_id,c.instance_id
        ,tr.to_agent.id to_agent_id
        FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
        left JOIN UNNEST (c.transfers) AS tr
      )tr on hd.call_id = tr.call_id and hd.instance_id = tr.instance_id and hd.interaction_agent_id = tr.to_agent_id
      left join
      @{PROJECT_NAME}.@{DATASET}.`t_agents` a
      on hd.interaction_agent_id = a.id and hd.instance_id = a.instance_id
      left join
      (
        --Agent Order
        select c.id call_id,c.instance_id,ao.agent_id,row_number() over (partition by c.id order by ao.id)agent_order,ao.id
        FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
        LEFT JOIN UNNEST (c.handle_durations) AS ao
        where ao.call_duration > 0
      ) ao on hd.call_id = ao.call_id and hd.instance_id = ao.instance_id and hd.interaction_agent_id = ao.agent_id
      ;;
  }

  ####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################

  dimension: call_id
  {
    description: "ID for each Call"
    primary_key: yes
    type: number
    sql: ${TABLE}.call_id;;
  }

  dimension: instance_id
  {
    type: number
    sql: ${TABLE}.instance_id ;;
  }

  dimension: agent_id_interaction
  {
    description: "Agent ID of the Interaction"
    type: string
    sql: ${TABLE}.interaction_agent_id ;;
  }
  dimension: agent_name_interaction
  {
    description: "Agent Name of the Interaction"
    type: string
    sql: ${TABLE}.interaction_agent_name ;;
  }

  dimension: agent_handled_call
  {
    description: "Flag to indicate if the agent handled the call"
    type: number
    sql: ${TABLE}.agent_handled ;;
  }

  dimension:transfer_placed
  {
    description: "Transactions Made by the Agent"
    type: number
    sql: ${TABLE}.transfer_placed ;;
  }

  dimension: transfer_received
  {
    description: "Transactions Received by the Agent"
    type: number
    sql: ${TABLE}.transfer_received ;;
  }

  dimension: call_type
  {
    description: "Type on the Call: Inbound, Outbound, etc."
    type: string
    sql: ${TABLE}.call_type ;;
  }

  dimension: call_duration
  {
    description: "Duration of the Interaction(Leg)"
    type: number
    sql: ${TABLE}.call_duration ;;
  }

  dimension: wrapup_duration
  {
    description: "Wrap Up Duration of the Interaction(Leg)"
    type: number
    sql: ${TABLE}.acw_duration ;;
  }

  dimension: wrapup_duration_hms
  {
    description: "Wrap Up Duration of the Interaction(Leg) (in HH:MM:SS)"
    type: number
    sql: ${wrapup_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: bcw_duration
  {
    description: "Befoe Call Work Duration of the Interaction(Leg)"
    type: number
    sql: ${TABLE}.bcw_duration ;;
  }

  dimension: hold_duration
  {
    description: "Hold Duration of the Interaction(Leg) (in seconds)"
    type: number
    sql: ${TABLE}.hold_duration ;;
  }

  dimension: hold_duration_hms
  {
    description: "Hold Duration of the Interaction(Leg) (in HH:MM:SS)"
    type: number
    sql: ${hold_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: handle_duration
  {
    description: "Wrapup+BeforeCallWork+CallDuration (in seconds)"
    type: number
    sql: ${wrapup_duration} + ${bcw_duration} + ${call_duration} ;;
  }

  dimension: handle_duration_hms
  {
    description: "Wrapup+BeforeCallWork+CallDuration in (HH:MM:SS)"
    type: number
    sql: ${handle_duration}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: talk_duration
  {
    description: "Handle Time minus Hold Time minus Wrap Time (in seconds)"
    type: number
    sql: ${handle_duration}-${hold_duration}-${wrapup_duration} ;;
  }

  dimension: talk_duration_hms
  {
    description: "Handle Time minus Hold Time minus Wrap Time (in HH:MM:SS)"
    type: number
    sql: (${handle_duration}-${hold_duration}-${wrapup_duration})/86400.0 ;;
  }

  ####################################################################################
  ####################################    MEASURES   #################################
  ####################################################################################


  measure: total_transfers_made
  {
    group_label: "Totals"
    label: "Total Transfers Made"
    type: sum
    sql: ${transfer_placed} ;;
  }

  measure: total_transfers_received
  {
    group_label: "Totals"
    label: "Total Transfers Received"
    type: sum
    sql: ${transfer_received} ;;
  }

  measure: total_calls_handled
  {
    group_label: "Totals"
    label: "Total Handled"
    type: sum
    sql: ${agent_handled_call} ;;

  }

  measure: outbound_calls_handled
  {
    group_label: "Totals"
    description: "Calls where Call Type = Voice Outbound"
    type: count
    filters: [call_type: "Voice Outbound"]
  }

  measure: total_talk_duration
  {
    group_label: "Totals"
    label: "Total Talk Time"
    type: sum
    sql: ${talk_duration} ;;
  }

  measure: total_hold_duration
  {
    group_label: "Totals"
    label: "Total Hold Time"
    type: sum
    sql: ${hold_duration} ;;
  }

  measure: total_wrapup_duration
  {
    group_label: "Totals"
    label: "Total Wrapup Time"
    type: sum
    sql: ${wrapup_duration} ;;
  }

  measure: total_handle_duration
  {
    group_label: "Totals"
    label: "Total Handle Time"
    type: sum
    sql: ${handle_duration} ;;

  }
  #Averages
  measure: avg_talk_duration
  {
    description: "Avg of (Handle Time minus Hold Time minus Wrap Time) (in HH:MM:SS)"
    group_label: "Avg"
    label: "Avg Talk Time"
    type: average
    sql: ${talk_duration_hms} ;;
    value_format_name: HMS
  }

  measure: avg_hold_duration
  {
    group_label: "Avg"
    label: "Avg Hold Time"
    description: "Avg Hold Duration of the Interaction(Leg) in HH:MM:SS"
    type: average
    sql: ${hold_duration_hms} ;;
    value_format_name: HMS
  }

  measure: avg_wrapup_duration
  {
    group_label: "Avg"
    label: "Avg Wrapup Time"
    type: average
    sql: ${wrapup_duration_hms} ;;
    value_format_name: HMS
  }

  measure: avg_handle_duration
  {
    group_label: "Avg"
    label: "Avg Handle Time"
    type: average
    sql: ${handle_duration_hms} ;;
    value_format_name: HMS
  }

}
