view: team_structure
{
  ## View for Teams
  derived_table:
  {
    sql: SELECT * FROM @{PROJECT_NAME}.@{DATASET}.`v_teams_hierarchy` ;;
  }
  ####################################################################################
  #####################################   DIMENSIONS   ###############################
  ####################################################################################

  dimension: agent_id
  {
    description: "Agent ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: agent_name
  {
    description: "Agent Name"
    type: string
    sql: ${TABLE}.agent_name ;;
  }

  dimension: instance_id
  {
    type: number
    sql: ${TABLE}.instance_id ;;
  }

  dimension: sub_team
  {
    label: "Sub Team"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: team_work_center
  {
    label: "Team Work Center"
    type: string
    sql: ${TABLE}.level2;;
  }

  dimension: team_company
  {
    label: "Team Company"
    type: string
    #sql: concat (${TABLE}.level2 , ${TABLE}.level3) ;;
    sql: ${TABLE}.level1 ;;
  }
}
