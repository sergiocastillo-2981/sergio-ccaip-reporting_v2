- dashboard: agent_activity_timeline
  title: Agent Activity Timeline
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  preferred_slug: jLCMkBjPWIw50BMENcBzRR
  elements:
  - title: Agent Activity Timeline
    name: Agent Activity Timeline
    model: "@{CCAIP_MODEL}"
    explore: agent_activity
    type: looker_grid
    fields: [agent_activity.agent_id, agent_activity.agent_name, agent_activity.status,
      agent_activity.activity, agent_activity.started_at_time, agent_activity.ended_at_time,
      agent_activity.duration_hms_string, agent_activity.call_id, agent_activity.chat_id]
    filters: {}
    sorts: [agent_activity.started_at_time]
    limit: 500
    column_limit: 50
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    listen:
      Date: agent_activity.started_at_date
      Agent Name: agent_activity.agent_name
    row: 0
    col: 0
    width: 24
    height: 12
  filters:
  - name: Date
    title: Date
    type: field_filter
    default_value: 7 day
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
      options: []
    model: "@{CCAIP_MODEL}"
    explore: agent_activity
    listens_to_filters: []
    field: agent_activity.started_at_date
  - name: Agent Name
    title: Agent Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: "@{CCAIP_MODEL}"
    explore: agent_activity
    listens_to_filters: []
    field: agent_activity.agent_name
