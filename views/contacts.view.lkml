view: contacts
{
  ## View for contacts (calls and chats)
  derived_table:
  {
    sql:
      SELECT distinct c.id as contact_id
          ,c.instance_id
          ,c.instance_name
          ,CAST(c.created_at AS timestamp) as started_at
          ,CAST(c.ends_at AS timestamp) as ended_at
          --,c.brand_id
          --,c.brand_name
          ,call_type as contact_type
          ,'phone' as contact_category
          ,agent_info.id agent_id
          ,agent_info.name as agent_info_name
          ,c.lang
          ,c.status
          ,c.fail_reason
          ,c.wait_duration
          ,c.queue_duration
          ,qd.in_sla
          ,qd.not_in_sla
          ,logical_or(IFNULL(tr.status, 'false')  ='transferred')transfer
          ,c.menu_path.name AS menu_path_name
          ,hd.acw_duration
          ,c.call_duration handle_duration
          ,c.hold_duration
          ,c.selected_menu.id selected_menu_id
          ,c.selected_menu.name selected_menu_name
      FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
          --left JOIN UNNEST (c.queue_durations) AS qd
          left join
          (
            select c.id,c.instance_id,sum(case when qd.service_level_event = 'in_sla'then 1 else 0 end)in_sla
            ,sum(case when qd.service_level_event = 'not_in_sla'then 1 else 0 end)not_in_sla
            FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
            left JOIN UNNEST (c.queue_durations) AS qd
            group by c.id,c.instance_id
          )qd on c.id = qd.id and c.instance_id = qd.instance_id
          left join
          (
            select c.id,c.instance_id,sum(hd.acw_duration)acw_duration
            FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
            left JOIN UNNEST (c.handle_durations) AS hd
            group by c.id,c.instance_id
          )hd on c.id = hd.id and c.instance_id = hd.instance_id
          left JOIN UNNEST (c.transfers) AS tr
      GROUP BY
          c.id
          --,c.brand_id
          --,c.brand_name
          ,c.instance_id
          ,c.instance_name
          ,c.created_at
          ,c.ends_at
          ,call_type
          ,agent_info.id
          ,agent_info.name
          ,c.lang
          ,c.status,c.fail_reason
          ,wait_duration,c.queue_duration,c.call_duration
          ,qd.in_sla
          ,qd.not_in_sla
          ,c.menu_path.name
          ,c.hold_duration
          ,hd.acw_duration
          ,c.selected_menu.id
          ,c.selected_menu.name
 --This section can be uncommented when there is chats on the system
      UNION ALL

      SELECT distinct c.id as contact_id
      ,c.instance_id
      ,c.instance_name
      ,CAST(c.created_at AS timestamp) as started_at
      ,CAST(c.ends_at AS timestamp) as ended_at
      --,c.brand_id
      --,c.brand_name
      ,chat_type as contact_type
      ,'chat' as contact_category
      ,agent_info.id agent_id
      ,agent_info.name as agent_info_name
      ,c.lang
      ,c.status
      ,c.fail_reason
      ,c.wait_duration
      ,c.queue_duration
      ,qd.in_sla
      ,qd.not_in_sla
      ,logical_or(IFNULL(tr.status, 'false')  ='transferred')transfer
      ,c.menu_path.name AS menu_path_name
      ,hd.acw_duration
      ,c.chat_duration handle_duration
      ,0 as hold_duration
      ,c.selected_menu.id selected_menu_id
      ,c.selected_menu.name selected_menu_name
      FROM @{PROJECT_NAME}.@{DATASET}.`t_chats` c
      left join
      (
      select c.id,c.instance_id,sum(case when qd.service_level_event = 'in_sla'then 1 else 0 end)in_sla
      ,sum(case when qd.service_level_event = 'not_in_sla'then 1 else 0 end)not_in_sla
      FROM @{PROJECT_NAME}.@{DATASET}.`t_chats` c
      left JOIN UNNEST (c.queue_durations) AS qd
      group by c.id,c.instance_id
      )qd on c.id = qd.id and c.instance_id = qd.instance_id
      left join
      (
      select c.id,c.instance_id,sum(hd.acw_duration)acw_duration
      FROM @{PROJECT_NAME}.@{DATASET}.`t_chats` c
      left JOIN UNNEST (c.handle_durations) AS hd
      group by c.id,c.instance_id
      )hd on c.id = hd.id and c.instance_id = hd.instance_id
      left JOIN UNNEST (c.transfers) AS tr
      GROUP BY
      c.id
      --,c.brand_id
      --,c.brand_name
      ,c.instance_id
      ,c.instance_name
      ,c.created_at
      ,c.ends_at
      ,chat_type
      ,agent_info.id
      ,agent_info.name
      ,c.lang
      ,c.status
      ,c.fail_reason
      ,wait_duration,c.queue_duration,c.chat_duration
      ,qd.in_sla
      ,qd.not_in_sla
      ,c.menu_path.name
      ,hd.acw_duration
      ,c.selected_menu.id
      ,c.selected_menu.name

      ;;
  }

  ####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################
  dimension: contact_id
  {
    description: "Unique ID for each Contact(Call-Chat)"
    primary_key: yes
    type: number
    sql: ${TABLE}.contact_id ;;
  }

  dimension: instance_id
  {
    type: number
    sql: ${TABLE}.instance_id ;;
  }

  parameter: select_timeframe
  {
    type: unquoted
    default_value: "contact_hour"

    allowed_value: {value:"contact_hour" label: "Hourly"}
    allowed_value: {value:"contact_date" label: "Daily" }
    allowed_value: {value:"contact_month" label: "Monthly"}
  }

  dimension: dynamic_timeframe
  {
    label_from_parameter: select_timeframe
    type: string
    sql:
        {% if select_timeframe._parameter_value == 'contact_hour' %}    ${contact_hour}
        {% elsif select_timeframe._parameter_value == 'contact_date' %} ${contact_date}
        {% else %}         ${contact_month}
        {% endif %}
        ;;
  }

  dimension_group: contact
  {
    type: time
    timeframes: [
      raw,
      time,
      date,
      hour,
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

  dimension: agent_id
  {
    label: "Agent ID"
    type: number
    sql: ${TABLE}.agent_id ;;
  }

  dimension: agent_name
  {
    label: "Agent Name"
    type: string
    sql: ${TABLE}.agent_info_name ;;
  }

  dimension: region
  {
    label: "Region"
    type: string
    sql: ${TABLE}.lang ;;
  }

  dimension: contact_category
  {
    description: "Identifies each contact as either chat or call"
    label: "LOB"
    type: string
    sql: ${TABLE}.contact_category ;;
  }

  dimension: contact_type
  {
    description: "Type on the contact"
    type: string
    sql: ${TABLE}.contact_type ;;
  }

  dimension: service_level_event {
    type: string
    sql: ${TABLE}.service_level_event ;;
  }

  dimension: in_sla
  {
    description: "Count of contacts where queue time is less than the SLA threshold"
    type: number
    sql: ${TABLE}.in_sla ;;
  }

  dimension: not_in_sla
  {
    description: "Count of contacts where queue time is greater than the SLA threshold"
    type: number
    sql: ${TABLE}.not_in_sla ;;
  }

  dimension: status
  {
    description: "The possible values are: scheduled, queued, assigned, connecting, switching, connected, finished, failed, recovered, deflected, selecting, action_only, action_only_finished, voicemail, voicemail_received, voicemail_read"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: fail_reason
  {
    description: "Description for a call that ended before successfully connected"
    type: string
    sql:  ${TABLE}.fail_reason ;;

  }

  dimension: handle_time_ss
  {
    description: "Amount of time that elapsed from when an agent was assigned a call, to when they ended their wrap-up phase"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.handle_duration ;;
  }

  dimension: handle_time_hms
  {
    description: "Amount of time that elapsed from when an agent was assigned a call, to when they ended their wrap-up phase"
    group_label: "Durations"
    type: number
    sql: ${handle_time_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: hold_time_ss
  {
    group_label: "Durations"
    description: "The sum of time (in seconds) an agent placed a consumer on hold during an interaction."
    type: number
    sql: ${TABLE}.hold_duration ;;
  }

  dimension: hold_time_hms
  {
    group_label: "Durations"
    description: "The sum of time (in seconds) an agent placed a consumer on hold during an interaction in HH:MM:SS"
    type: number
    sql: ${hold_time_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: talk_time_ss
  {
    group_label: "Durations"
    description: "Contact Duration(Handle Time) Minus Hold Duration"
    type: number
    sql: ${handle_time_ss}-${hold_time_ss} ;;
  }

  dimension: talk_time_hms
  {
    group_label: "Durations"
    description: "Contact Duration(Handle Time) Minus Hold Duration"
    type: number
    sql: (${handle_time_ss}-${hold_time_ss})/86400.0 ;;
    value_format_name: HMS
  }

  dimension: queue_time_ss
  {
    description: "Time spent waiting in Queue, also known as Wait Time"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: queue_time_hhmmss
  {
    description: "Time spent waiting in Queue, also known as Wait Time"
    group_label: "Durations"
    type: number
    sql: ${queue_time_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: wrapup_duration_ss
  {
    description: "Wraup Duration"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.acw_duration ;;
  }

  dimension: wrapup_duration_hms
  {
    description: "Wraup Duration in HH:MM:SS"
    group_label: "Durations"
    type: number
    sql: ${wrapup_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: transfer {
    type: yesno
    sql: ${TABLE}.transfer ;;
  }

  dimension: brand_id
  {
    type: number
    sql: ${TABLE}.instance_id ;;
  }

  dimension: brand_name
  {
    type: string
    sql: ${TABLE}.instance_name ;;
  }

  dimension: selected_menu_id
  {
    label: "Selected Menu ID"
    type: number
    sql: ${TABLE}.selected_menu_id ;;
  }

  dimension: selected_menu_name
  {
    label: "Selected Menu"
    type: string
    sql: ${TABLE}.selected_menu_name ;;
  }

  dimension: menu_path
  {
    label: "Queue"
    type: string
    sql: ${TABLE}.menu_path_name ;;
  }


  ####################################################################################
  ####################################    MEASURES   #################################
  ####################################################################################
  measure: count
  {
    group_label: "Totals"
    label: "Total Offered"
    type: count
    drill_fields: [contact_detail*]
  }

  measure: call_count
  {
    group_label: "Totals"
    label: "Total Calls"
    description: "Total number of calls within the selected time frame"
    type: count
    filters: [contact_category: "phone"]
    #link:
    #{
    #  label: "Calls Dashboard"
    #  url: "https://ttec.cloud.looker.com/dashboards/170?Call+Date={{_filters['overal_metrics.contact_date']|url_encode}}"
    #}
  }

  measure: chat_count
  {
    group_label: "Totals"
    label: "Total Chats"
    description: "Total number of chats within the selected time frame"
    type: count
    filters: [contact_category: "chat"]
    #link:
    #{
    #  label: "Chats Dashboard"
    #  #url: "https://ttec.cloud.looker.com/dashboards/171?Agent+ID={{ v_agent_activity_logs.agent_id._value }}&Activity+Date={{_filters['v_agent_activity_logs.activity_date']|url_encode}}"
    #  url: "https://ttec.cloud.looker.com/dashboards/187?Chat+Date={{_filters['overal_metrics.contact_date']|url_encode}}"
    #}
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

  measure: count_handled
  {
    group_label: "Totals"
    label: "Total Handled"
    description: "The sum of Conversations where status=finished and fail_reason=nothing"
    type: count
    filters: [status: "finished" ,fail_reason: "nothing"]
  }

  measure: total_abandoned
  {
    group_label: "Totals"
    label: "Total Abandoned"
    description: "The sum of Contacts that were abandoned by the consumer while waiting in queue"
    type: count
    filters: [fail_reason: "eu_abandoned"]

  }

  measure: total_short_abandoned
  {
    group_label: "Totals"
    label: "Total Short Abandoned"
    description: "The sum of Contacts that were abandoned within 10 seconds by the consumer while waiting in queue"
    type: count
    filters: [fail_reason: "eu_abandoned", queue_time_ss: "<10"]
  }

  measure: count_transfers
  {
    group_label: "Totals"
    label: "Total Transfers"
    description: "Total Number of Transfers "
    type: count
    filters: [transfer: "Yes"]
    #drill_fields: [transfer_type,agent_id]
    value_format_name: decimal_0
  }

  measure: total_queue_time
  {
    description: "Total Time calls spent on the queue (in seconds)"
    group_label: "Totals"
    type: sum
    sql: ${queue_time_ss} ;;
  }

  measure: total_queue_time_hms
  {
    description: "Total Time calls spent on the queue (in hh:mm:ss)"
    group_label: "Totals"
    type: sum
    sql: ${queue_time_hhmmss} ;;
    value_format_name: HMS
  }

  measure: perc_in_sla
  {
    group_label: "Percent"
    label: "SLA %"
    description: "Count of Contacts In SLA /(Count of Contacts  In SLA + count of Contacts Out SLA"
    type: number
    #sql: ${count_in_sla} / ${count} ;;
    sql: case when (${count_in_sla} + ${count_out_sla}) = 0 then 0 else ${count_in_sla} / (${count_in_sla} + ${count_out_sla}) end;;
    value_format_name: percent_2
  }

  measure: perc_handled
  {
    group_label: "Percent"
    label: "Handled %"
    description: "Contacts Handled vs Contacts Offered"
    type: number
    sql:  ${count_handled}/${count};;
    value_format_name: percent_2
  }

  measure: perc_abandoned
  {
    group_label: "Percent"
    label: "Abandoned %"
    description: "Contacts Abandoned vs Contacts Offered"
    type: number
    sql:  ${total_abandoned}/${count};;
    value_format_name: percent_2
  }

  measure: perc_transfers
  {
    group_label: "Percent"
    label: "Transfer %"
    description: "Contacts Transfered vs Contacts Offered"
    type: number
    sql:  ${count_transfers}/${count};;
    value_format_name: percent_2
  }

  measure: avg_handle_time_hhmmss
  {
    group_label: "Avg"
    label: "Avg Handle Time HH:MM:SS"
    type: average
    sql: ${handle_time_hms} ;;
    value_format_name: HMS
  }

  measure: avg_handle_time_ss
  {
    group_label: "Avg"
    label: "Avg Handle Time (Seconds)"
    type: average
    sql: ${handle_time_ss} ;;
  }

  measure: avg_queue_duration_hhmmss
  {
    group_label: "Avg"
    label: "Avg Speed of Answer (Avg Queue Time) HH:MM:SS"
    type: average
    sql: ${queue_time_hhmmss} ;;
    value_format_name: HMS
  }

  measure: avg_queue_duration_ss
  {
    group_label: "Avg"
    label: "Avg Queue Time (Seconds)"
    type: average
    sql: ${queue_time_ss} ;;
    #value_format_name: HMS
  }

  measure: avg_queue_time
  {
    group_label: "Avg"
    label: "Avg Speed of Answer"
    description: "Avg Queue Time"
    type: average
    sql: ${queue_time_ss} ;;
  }

  measure: avg_aband_time
  {
    group_label: "Avg"
    label: "Avg Abandon Time(Seconds)"
    description: "Queue Time / Calls abandoned"
    type: number
    sql: case when ${total_abandoned} = 0 then 0 else  ${total_queue_time}/${total_abandoned} end;;
  }

  measure: avg_aband_time_hms
  {
    group_label: "Avg"
    label: "Avg Abandon Time(hh:mm:ss)"
    description: "Queue Time / Calls abandoned  in hh:mm:ss format"
    type: number
    sql: case when ${total_abandoned} = 0 then 0 else  ${total_queue_time_hms}/${total_abandoned} end;;
    value_format_name: HMS

  }

  measure: avg_talk_time
  {
    group_label: "Avg"
    label: "Avg Talk Time(Seconds)"
    description: "Avg (Handle Time minus Hold Time)"
    type: average
    sql: ${talk_time_ss} ;;
  }

  measure: avg_talk_time_hms
  {
    group_label: "Avg"
    label: "Avg Talk Time(HH:MM:SS)"
    description: "Avg (Handle Time minus Hold Time) in HH:MM:SS Format"
    type: average
    sql: ${talk_time_hms} ;;
    value_format_name: HMS
  }

  measure: avg_hold_time
  {
    group_label: "Avg"
    label: "Avg Hold Time(Seconds)"
    type: average
    sql: ${hold_time_ss} ;;
  }

  measure: avg_hold_time_hms
  {
    group_label: "Avg"
    label: "Avg Hold Time(HH:MM:SS)"
    description: "The avg time (in HH:MM:SS) an agent placed a consumer on hold during interactions"
    type: average
    sql: ${hold_time_hms} ;;
    value_format_name: HMS
  }

  measure: avg_wrapup_time
  {
    group_label: "Avg"
    type: average
    sql: ${wrapup_duration_ss} ;;
  }


  measure: avg_wrapup_time_hms
  {
    group_label: "Avg"
    label: "Avg Wrapup Time(HH:MM:SS)"
    type: average
    sql: ${wrapup_duration_hms} ;;
    value_format_name: HMS
  }


  set: contact_detail
  {
    fields:
    [
      contact_id,
      contact_date,
      contact_category
    ]
  }


}
