- dashboard: queue_transactional_report
  title: Queue Transactional Report
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: true
  description: ''
  preferred_slug: eh47TMxhHTiwrnEpFg2tYo
  elements:
  - title: All Queued Interactions
    name: All Queued Interactions
    model: "@{CCAIP_MODEL}"
    explore: queue_transactional
    type: looker_grid
    fields: [call_details.call_id, call_details.support_number, call_details.outbound_number,
      call_details.session_type_v2, call_details.answer_type, call_queued_interactions.qd_queue_name,
      call_queued_interactions.qd_interaction_id, call_queued_interactions.qd_interaction_start_time,
      call_queued_interactions.qd_interaction_end_time, call_queued_interactions.agent_id,
      call_queued_interactions.agent_name, call_queued_interactions.queue_duration_hms,
      call_queued_interactions.service_level_event, call_queued_interactions.language,
      call_queued_interactions.transferred, call_queued_interactions.qd_team_company,
      call_queued_interactions.interaction_status]
    sorts: [call_queued_interactions.qd_interaction_id]
    limit: 5000
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
      Call ID: call_details.call_id
      Instance Name: call_details.brand_name
      Team Company: call_queued_interactions.qd_team_company
      Interaction Start Time: call_queued_interactions.qd_interaction_start_time
    row: 0
    col: 0
    width: 24
    height: 7
  - title: All Handled Interactions
    name: All Handled Interactions
    model: "@{CCAIP_MODEL}"
    explore: queue_transactional
    type: looker_grid
    fields: [call_details.call_id, call_details.session_type_v2, call_details.answer_type,
      call_details.support_number, call_details.outbound_number, call_handled_interactions.hd_queue_name,
      call_handled_interactions.hd_interaction_id, call_handled_interactions.hd_interaction_start_time,
      call_handled_interactions.hd_interaction_end_time, call_handled_interactions.agent_id,
      call_handled_interactions.agent_name, call_handled_interactions.call_duration_hms,
      call_handled_interactions.acw_duration_hms, call_handled_interactions.hi_status,
      call_handled_interactions.hd_team_company]
    sorts: [call_handled_interactions.hd_interaction_id]
    limit: 5000
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
      Call ID: call_details.call_id
      Instance Name: call_details.brand_name
      Team Company: call_handled_interactions.hd_team_company
      Interaction Start Time: call_handled_interactions.hd_interaction_start_time
    row: 7
    col: 0
    width: 24
    height: 7
  filters:
  - name: Instance Name
    title: Instance Name
    type: field_filter
    default_value: avast
    allow_multiple_values: true
    required: false
    ui_config:
      type: button_group
      display: inline
    model: "@{CCAIP_MODEL}"
    explore: queue_transactional
    listens_to_filters: []
    field: call_details.brand_name
  - name: Interaction Start Time
    title: Interaction Start Time
    type: field_filter
    default_value: 4 hour
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
      options: []
    model: "@{CCAIP_MODEL}"
    explore: queue_transactional
    listens_to_filters: []
    field: call_queued_interactions.qd_interaction_start_time
  - name: Call ID
    title: Call ID
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
      options: []
    model: "@{CCAIP_MODEL}"
    explore: queue_transactional
    listens_to_filters: []
    field: call_details.call_id
  - name: Team Company
    title: Team Company
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: "@{CCAIP_MODEL}"
    explore: queue_transactional
    listens_to_filters: [Instance Name]
    field: call_handled_interactions.hd_team_company
