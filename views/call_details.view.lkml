view: call_details
{
  label: "Call Details"
  derived_table:
  {

    sql:
        SELECT distinct c.id as call_id,c.instance_id,c.instance_name
          ,CAST(c.created_at AS timestamp) as started_at
          ,CAST(c.ends_at AS timestamp) as ended_at
          --,c.brand_id
          --,c.brand_name
          ,call_type
          ,agent_info.id agent_id
          ,agent_info.name as agent_info_name
          ,c.lang
          ,c.status
          ,c.fail_reason
          ,c.wait_duration
          ,c.queue_duration
          ,c.recording_url
          ,v.link
          --,v.encrypted_id
          ,c.menu_path.name AS menu_path_name
          ,c.call_duration handle_duration
          ,c.hold_duration
          ,hd.acw_duration
          ,c.selected_menu.id selected_menu_id
          ,c.selected_menu.name selected_menu_name
          ,c.session_type_v2
          ,c.answer_type
          ,c.support_number
          ,c.outbound_number
      FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
          LEFT JOIN @{PROJECT_NAME}.@{DATASET}.`v_recordings` v
            ON c.id = v.id and c.instance_id = v.instance_id
          LEFT JOIN
          (--this is to get one acw_duration per call
            select c.id,c.instance_id,sum(hd.acw_duration)acw_duration
            FROM @{PROJECT_NAME}.@{DATASET}.`t_calls` c
            left JOIN UNNEST (c.handle_durations) AS hd
            group by c.id,c.instance_id
          )hd on c.id = hd.id and c.instance_id = hd.instance_id
        ;;
  }


  ####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################
  dimension: call_id
  {
    description: "Unique ID for each call"
    primary_key: yes
    type: number
    value_format: "#######"
    sql: ${TABLE}.call_id ;;
  }

  dimension: instance_id
  {
    type: number
    sql: ${TABLE}.instance_id ;;
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

  dimension_group: call_start
  {
    type: time
    datatype: timestamp
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
    drill_fields: [call_detail*]
  }

  dimension_group: call_end
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
    drill_fields: [call_detail*]
  }

  dimension: call_type
  {
    type: string
    sql: ${TABLE}.call_type ;;
  }

  dimension: disconnected_by
  {
    type: string
    sql:  INITCAP(SUBSTR(${TABLE}.disconnected_by, 17))   ;;
  }

  dimension: call_queue_name
  {
    type: string
    sql: ${TABLE}.menu_path_name ;;
  }

  dimension: recording_link
  {
     #Original Recording Stored on the table
    sql: ${TABLE}.recording_url ;;
    link:
    {
      label: "Recording URL"
      url: "{{value}}"
    }
  }


  dimension: recording_link_bucket
  {
    #Recording Stored on the GCP Bucket, the recording must be on the same connection as the looker connection
    sql:  ${TABLE}.link;;
    #Link to the Recording
    #html: <a href="{{value}}" target="_blank"><img src="https://icon-library.com/images/icon-sound/icon-sound-1.jpg" alt="Recording Link" style="width:32px;height:32px";></a> ;;

    #Embeded Recording
    html:
        <audio controls controlsList="nodownload">
        <source src="{{value}}"  type="audio/mpeg">
        </audio>
      ;;
  }

  #dimension: recording_url_embedded
  #{
  #  #sql: case when ${status} = 'failed' then 'no recording' else ${recording_url_link} end;;
  #  sql: ${TABLE}.link ;;
  #  html:
  #    <audio controls controlsList="nodownload">
  #    <source src="{{value}}"  type="audio/mpeg">
  #    </audio>
  #  ;;
  #}

  #dimension: recording_status
  #{
  #  sql: CASE WHEN ${status} = 'failed' THEN 'No Recording Available due to failure'
  #            WHEN ${TABLE}.link IS NULL THEN 'Call Not Recorded'
  #            ELSE 'Recording Successful' END;;
  #}

  dimension: session_type_v2
  {
    type: string
    sql: ${TABLE}.session_type_v2 ;;
  }

  dimension: answer_type
  {
    type: string
    sql: ${TABLE}.answer_type ;;
  }

  dimension: support_number
  {
    type: string
    sql: ${TABLE}.support_number ;;
  }

  dimension: outbound_number
  {
    type: string
    sql: ${TABLE}.outbound_number ;;
  }

  dimension: handle_duration_ss
  {
    description: "Handle duration includes ACW Duration, Call Duration and BCW Duration"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.handle_duration ;;
  }

  dimension: handle_duration_hhmmss
  {
    description: "Handle duration includes ACW Duration, Call Duration and BCW Duration"
    group_label: "Durations"
    type: number
    sql: ${handle_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }


  dimension: queue_duration_ss
  {
    description: "Time spent waiting in Queue, also known as Wait Time"
    group_label: "Durations"
    type: number
    sql: ${TABLE}.queue_duration ;;
  }

  dimension: queue_duration_hhmmss
  {
    description: "Time spent waiting in Queue, also known as Wait Time"
    group_label: "Durations"
    type: number
    sql: ${queue_duration_ss}/86400.0 ;;
    value_format_name: HMS
  }

  dimension: hold_duration
  {
    description: "Hold Time"
    type: number
    sql: ${TABLE}.hold_duration ;;
  }

  dimension: acw_duration
  {
    description: "Wraup Time"
    type: number
    sql:  ${TABLE}.acw_duration ;;
  }

  dimension: status
  {
    description: "The possible values are: scheduled, queued, assigned, connecting, switching, connected, finished, failed, recovered, deflected, selecting, action_only, action_only_finished, voicemail, voicemail_received, voicemail_read"
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: agent_name
  {
    type: string
    sql: ${TABLE}.agent_info_name ;;
  }

  dimension: agent_id
  {
    type: string
    sql: ${TABLE}.agent_id ;;
  }

  dimension: fail_reason
  {
    description: "Description for a call that ended before successfully connected"
    type: string
    sql:  ${TABLE}.fail_reason ;;
  }

  dimension: fail_details
  {
    description: " Description of failure for a call that ended before successfully connected"
    type: string
    sql:  ${TABLE}.fail_details ;;
  }

  ##########################################################################################
  #############################################    MEASURES  ###############################
  ##########################################################################################
  measure: count {
    type: count
    drill_fields: [call_detail*]
  }

  measure: total_short_abandoned
  {
    group_label: "Totals"
    label: "Total Short Abandoned"
    description: "Number of Calls that were abandoned within 10 seconds by the consumer while waiting in queue"
    type: count
    filters: [fail_reason: "eu_abandoned,eu_in_menu_abandoned", queue_duration_ss: "<=10"]
  }

  measure: total_abandoned
  {
    #This measure needs to be calculated at queue level as is part of the avg_aband_time
    group_label: "Totals"
    label: "Total Abandoned"
    description: "Calls abandoned by the consumer waiting in queue (fail_reason =eu_abandoned,eu_in_menu_abandoned)"
    type: count
    filters: [fail_reason: "eu_abandoned,eu_in_menu_abandoned"]
  }

  measure: total_other_failed
  {
    #This measure needs to be calculated at queue level as is part of the avg_aband_time
    group_label: "Totals"
    label: "Total Other Failures"
    description: "Calls Failed other reasons (fail_reason not eu_abandoned or eu_in_menu_abandoned)"
    type: count
    filters: [fail_reason: "-eu_abandoned,-eu_in_menu_abandoned",status: "failed"]
  }

  measure: total_status
  {
    #This measure needs to be calculated at queue level as is part of the avg_aband_time
    group_label: "Totals"
    label: "Total Other Status"
    description: "Calls with other status like deflected or recovered"
    type: count
    filters: [status: "-failed,-finished"]
  }

  measure: total_queue_time_ss
  {
    description: "Total Time calls spent on the queue (in hh:mm:ss)"
    group_label: "Totals"
    type: sum
    sql: ${queue_duration_ss} ;;
  }

  measure: count_handled
  {
    group_label: "Totals"
    label: "Total Handled"
    description: "The sum of Calls where status=finished and fail_reason=nothing"
    type: count
    filters: [status: "finished" ,fail_reason: "nothing"]
  }

  measure: sum_hold_duration
  {
    group_label: "Totals"
    label: "Total Hold Time"
    type: sum
    sql: ${hold_duration} ;;
  }

  measure: sum_wrapup_duration
  {
    group_label: "Totals"
    label: "Total Wrapup Time"
    type: sum
    sql: ${acw_duration} ;;
  }


  measure: total_handle_time
  {
    group_label: "Totals"
    type: sum
    sql: ${handle_duration_ss}  ;;
  }






# ----- Sets of fields for drilling ------
  set: call_detail {
    fields: [
      call_id,
      #call_date,
      #agent_type,
      agent_name,
      call_type,
      status
    ]
  }



}
