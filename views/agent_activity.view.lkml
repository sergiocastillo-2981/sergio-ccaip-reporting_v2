view: agent_activity
{
  #sql_table_name: `ppp-csis-ccaiacc-57.ccaip_gendigital_reporting.t_agent_activity_logs` ;;
  derived_table:
  {
    #sql:
    #SELECT id,agent_id,duration
    #,CAST(started_at AS timestamp) as started_at
    #,CAST(ended_at AS timestamp) as ended_at,
    #instance_id,instance_name,status,activity
    #FROM @{PROJECT_NAME}.@{DATASET}.`t_agent_activity_logs`
    #;;

    sql:
    SELECT aa.id,aa.agent_id,concat(a.first_name,' ',a.last_name) agent_name,duration
    ,CAST(started_at AS timestamp) as started_at
    ,CAST(ended_at AS timestamp) as ended_at,
    aa.instance_id,aa.instance_name,aa.status,activity,aa.call_id,aa.chat_id
    FROM @{PROJECT_NAME}.@{DATASET}.`t_agent_activity_logs` aa
    left join
    @{PROJECT_NAME}.@{DATASET}.`t_agents` a on aa.agent_id = a.id
    ;;
  }




  dimension: id
  {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
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

  dimension: agent_id
  {
    type: number
    sql: ${TABLE}.agent_id ;;
  }

  dimension: agent_name
  {
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: call_id
  {
    type: number
    sql: ${TABLE}.call_id ;;

    link: {
      label: "Queue Transactional Detail"
      #url: "https://ttec.cloud.looker.com/dashboards/171?Agent+ID={{ v_agent_activity_logs.agent_id._value }}"
      url: "https://ttec.cloud.looker.com/dashboards/sergio_ccaip_reporting::queue_transactional_report?Call%20ID={{ agent_activity.call_id._value }}"
    }



  }

  dimension: chat_id
  {
    type: number
    sql: ${TABLE}.chat_id ;;
  }

  dimension: duration
  {
    type: number
    sql: ${TABLE}.duration ;;
  }

  dimension: duration_hms
  {
    description: "Time Spent on the status(In HH:MM:SS)"
    type: number
    sql: ${duration}/86400.0 ;;
    value_format_name: HMS
  }

  #dimension: duration_hms_new
  #{
  #  description: "Time Spent on the status(In Seconds)"
  #  type: string
  #  sql: regexp_replace( cast(time(${TABLE}.ts) as string), r'^\d\d', cast(extract(hour from time(${TABLE}.ts)) + 24 * unix_date(date(${TABLE}.ts)) as string) ) ;;
  #  #value_format_name: HMS
  #}

  dimension: duration_hms_string
  {
    type: string
    sql: concat
          (

      case when (cast(  FLOOR(duration/3600) as INT64) ) < 10 THEN "0" ELSE "" END
      , cast(cast(FLOOR(duration/3600) as INT64) as string)
      , ":"
      , CASE WHEN CAST(FLOOR( MOD(duration,3600)/60 ) as INT64) < 10 THEN "0" ELSE "" END
      , CAST(CAST(FLOOR( MOD(duration,3600)/60 ) as INT64) as STRING)
      , ":"
      , CASE WHEN CAST(MOD(MOD(duration,3600),60) as INT64) < 10 THEN "0" ELSE "" END
      , CAST(CAST(MOD(MOD(duration,3600),60) as INT64) as STRING)
      )
      ;;
  }

  dimension: duration_hrs
  {
    type: number
    sql: (${duration}/60.0)/60.0 ;;
    value_format_name: decimal_2
  }

  dimension: instance_id
  {
    type: number
    sql: ${TABLE}.instance_id ;;
  }

  dimension: instance_name
  {
    type: string
    sql: ${TABLE}.instance_name ;;
  }

  dimension_group: started_at
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
    drill_fields: [detail*]
  }

  dimension_group: ended_at
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
    drill_fields: [detail*]
  }

  dimension: in_call_time_hrs
  {
    type: number
    sql: CASE WHEN ${status} = 'In-call' THEN ${duration_hrs} ELSE 0 END   ;;
    value_format_name: decimal_2
  }

  dimension: wrapup_time_hrs
  {
    type: number
    sql: CASE WHEN ${status} = 'Wrap-up' THEN ${duration_hrs} ELSE 0 END  ;;
    value_format_name: decimal_2

  }

  dimension: available_time_ss
  {
    type: number
    sql: CASE WHEN ${status} = 'Available' THEN ${duration} ELSE 0 END  ;;
  }

  dimension: available_time_hrs
  {
    description: "Time Spent on the status Available (In Hours)"
    type: number
    sql: CASE WHEN ${status} = 'Available' THEN ${duration_hrs} ELSE 0 END  ;;
    value_format_name: decimal_2
  }

  dimension: available_time_hms
  {
    description: "Time Spent on the status Available (In HH:MM:SS)"
    type: number
    sql: CASE WHEN ${status} = 'Available' THEN ${duration_hms} ELSE 0 END  ;;
    value_format_name: HMS
  }

  dimension: break_time_hrs
  {
    description: "Break + Meal Times"
    type: number
    sql: CASE WHEN ${status} in ('Break','Meal') THEN ${duration_hrs} ELSE 0 END  ;;
    value_format_name: decimal_2
  }

  dimension: no_break_time_hrs
  {
    type: number
    sql: CASE WHEN ${status} not in ('Break','Meal') THEN ${duration_hrs} ELSE 0 END  ;;
    value_format_name: decimal_2
  }

  dimension: active_time_hrs
  {
    description: "All Activity Time - Break - Meal"
    type: number
    sql: ${duration_hrs}-${break_time_hrs} ;;
    value_format_name: decimal_2
  }

  dimension: status
  {
    type: string
    sql: ${TABLE}.status.name ;;
  }

  dimension: activity
  {
    type: string
    sql: ${TABLE}.activity ;;

  }

  ####################################################################################
  ####################################    MEASURES   #################################
  ####################################################################################
  measure: count
  {
    type: count
    drill_fields: [detail*]
  }

  measure: sum_occupied_time_hrs
  {
    group_label: "Totals"
    description: "(In Call + Wrap up Time) "
    type: sum
    sql: (${in_call_time_hrs} + ${wrapup_time_hrs})  ;;
  }

  measure: sum_busy_time_hrs
  {
    group_label: "Totals"
    description: "(In Call + Wrap up Time + Available Time )"
    type: sum
    sql:  (${in_call_time_hrs} + ${wrapup_time_hrs} + ${available_time_hrs});;
  }

  measure: sum_active_time_hrs
  {
    group_label: "Totals"
    description: "All Activity Time - Break - Meal"
    type: sum
    sql: ${active_time_hrs} ;;
    value_format_name: decimal_2
  }

  measure: sum_break_time_hrs
  {
    group_label: "Totals"
    description: "Sum Break + Meal Times"
    type: sum
    sql: ${break_time_hrs} ;;
    value_format_name: decimal_2
  }

  measure: sum_available_time_ss
  {
    type: sum
    sql: ${available_time_ss};;
  }

  measure: sum_available_time_hms
  {
    group_label: "Totals"
    description: "Total Time Spent on the status Available (In HH:MM:SS)"
    type: sum
    sql: ${available_time_hms};;
    value_format_name: HMS
  }

  measure: ocupancy
  {
    description: "(In Call + Wrap up Time) / (In Call + Wrap up Time + Available Time )"
    sql: CASE WHEN ${sum_busy_time_hrs} = 0 THEN 0 ELSE  ${sum_occupied_time_hrs}/${sum_busy_time_hrs} END ;;
    value_format_name: percent_2
  }

  measure: utilization
  {
    description: "Sum Busy Time / Sum Active Time"
    sql: CASE WHEN ${sum_active_time_hrs} = 0 THEN 0 ELSE ${sum_busy_time_hrs} / ${sum_active_time_hrs} END;;
    value_format_name: percent_2
  }

  measure: total_duration
  {
    group_label: "Totals"
    type: sum
    sql: ${duration} ;;
  }

  measure: total_duration_hrs
  {
    group_label: "Totals"
    type: sum
    sql: ${duration_hrs} ;;
    value_format_name: decimal_2
  }

  measure: total_duration_hms_string
  {
    group_label: "Totals"
    type: string
    sql:   concat
              (
              case when (cast(  FLOOR(${total_duration}/3600) as INT64) ) < 10 THEN "0" ELSE "" END
              , cast(cast(FLOOR(${total_duration}/3600) as INT64) as string)
              , ":"
              , CASE WHEN CAST(FLOOR( MOD(${total_duration},3600)/60 ) as INT64) < 10 THEN "0" ELSE "" END
              , CAST(CAST(FLOOR( MOD(${total_duration},3600)/60 ) as INT64) as STRING)
              , ":"
              , CASE WHEN CAST(MOD(MOD(${total_duration},3600),60) as INT64) < 10 THEN "0" ELSE "" END
              , CAST(CAST(MOD(MOD(${total_duration},3600),60) as INT64) as STRING)
              )
    ;;
  }

  measure: percent_of_total_duration {
    type: percent_of_total
    sql: ${total_duration_hrs} ;;
    #value_format_name: percent_2
    #value_format: "##.##"
  }


  # ----- Sets of fields for drilling ------
  set: detail
  {
    fields:
    [
      id,
      instance_name,
      brand_name,
      status
    ]
  }

}
