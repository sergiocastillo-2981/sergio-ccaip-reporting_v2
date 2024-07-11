# Define the database connection to be used for this model.
#connection: "sergio_ccaip_reporting"
connection: "@{CONNECTION_NAME}"

# include all the views
include: "/views/**/*.view"


#Dashboards(These need to be included on the model in order to show on the LookML Dashboard Folder)
#include: "/dashboards/contacts_overal.dashboard.lookml"
#include: "/dashboards/queue_transactional_report.dashboard.lookml"
include: "/dashboards/*.dashboard"

datagroup: ccaip_reporting_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: ccaip_reporting_default_datagroup


explore: contacts
{
  label: "Contacts"
  join: team_structure
  {
    #view_label: "Team Structure"
    type: left_outer
    sql_on: ${contacts.agent_id} = ${team_structure.agent_id} and ${contacts.instance_id} = ${team_structure.instance_id};;
    relationship: many_to_one
  }
}

explore: call_details
{
  view_name: call_details
  join: team_structure
  {
    #view_label: "Team Structure"
    type: left_outer
    sql_on: ${call_details.agent_id} = ${team_structure.agent_id} and ${call_details.instance_id} = ${team_structure.instance_id};;
    #
    relationship: many_to_one
  }
}

#explore: call_recordings_segmented
#{
#  extends: [call_details]
#  access_filter:
#  {
#    field: team_structure.team_company
#    user_attribute: company
#  }
#  access_filter:
#  {
#    field: call_details.brand_name
#    user_attribute: brand
#  }
#}

explore: agent_activity
{
  label: "Agent Activity"

  #This Team Structure was made for a specific customer need to come up wit a new structure
  #join: team_structure
  #{
  #  type: left_outer
  #  sql_on: ${agent_activity.agent_id} = ${team_structure.agent_id} and ${agent_activity.instance_id} = ${team_structure.instance_id} ;;
  #  relationship: many_to_one
  #}
}

explore: agent_performance
{
  join: call_details
  {
    type: inner
    sql_on: ${agent_performance.call_id} = ${call_details.call_id} and ${agent_performance.instance_id} = ${call_details.instance_id};;
    relationship: many_to_one
  }
  join: team_structure
  {
    #view_label: "Team Structure"
    type: left_outer
    sql_on: ${agent_performance.agent_id_interaction} = ${team_structure.agent_id} and ${agent_performance.instance_id} = ${team_structure.instance_id};;
    relationship: many_to_one
  }
  #join: agent_activity
  #{
  #  type: inner
  #  sql_on: ${agent_performance.agent_id_interaction} = ${agent_activity.agent_id} and ${agent_performance.instance_id} = ${agent_activity.instance_id};;
  #  relationship: one_to_many
  #}
}

explore: queue_transactional
{
  view_name: call_details
  join: call_handled_interactions
  {
    #type: left_outer #changed to inner to avoid calls with no interactions
    type: inner
    view_label:"Handle Interactions"
    sql_on: ${call_details.call_id} = ${call_handled_interactions.call_id} and ${call_details.instance_id} = ${call_handled_interactions.instance_id} ;;
    relationship: one_to_many
  }
  join: call_queued_interactions
  {
    #type: left_outer #changed to inner to avoid calls with no interactions
    view_label:"Queue Interactions"
    type: inner
    sql_on: ${call_details.call_id} = ${call_queued_interactions.call_id} and ${call_details.instance_id} = ${call_queued_interactions.instance_id}  ;;
    relationship: one_to_many
  }
}

explore: queue_summary
{
  #view_name: v_call_interactions

  view_name: call_details
  join: call_interactions
  {
    type: inner
    view_label: "Interaction Details"
    sql_on: ${call_details.call_id} = ${call_interactions.call_id} and ${call_details.instance_id} = ${call_interactions.instance_id} ;;
    relationship: one_to_many
  }
  join: team_structure
  {
    type: left_outer
    sql_on: ${call_interactions.agent_id} = ${team_structure.agent_id} and ${call_interactions.instance_id} = ${team_structure.instance_id};;
    relationship: many_to_one
  }
}

named_value_format:HMS{
  value_format: "HH:MM:SS"
}
