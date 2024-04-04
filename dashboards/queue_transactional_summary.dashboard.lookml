- dashboard: queue_transactional_summary
  title: Queue Transactional Summary
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  preferred_slug: OVyvNVw62EWfmKsQogiaeR
  elements:
  - title: Queue Transactional Summary
    name: Queue Transactional Summary
    model: "@{CCAIP_MODEL}"
    explore: queue_summary
    type: table
    fields: [call_interactions.menu_path, call_interactions.count, call_interactions.interactions_handled,
      call_details.total_abandoned, call_interactions.avg_aband_time, call_interactions.perc_abandoned,
      call_details.total_short_abandoned, call_interactions.avg_speed_answer_hms,
      call_interactions.perc_in_sla, call_interactions.avg_talk_time_hms, call_interactions.avg_hold_time_hms,
      call_interactions.avg_wrapup_time_hms, call_interactions.avg_handle_time_hms]
    sorts: [call_interactions.menu_path]
    limit: 500
    column_limit: 50
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_pivots: {}
    defaults_version: 1
    transpose: false
    truncate_text: true
    size_to_fit: true
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    listen:
      Date Range: call_interactions.qi_started_date
      Brand Name: call_details.brand_name
      Queue Name: call_interactions.menu_path
    row: 0
    col: 0
    width: 24
    height: 11
  filters:
  - name: Date Range
    title: Date Range
    type: field_filter
    default_value: 4 hour
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
      options: []
    model: "@{CCAIP_MODEL}"
    explore: queue_summary
    listens_to_filters: []
    field: call_interactions.qi_started_date
  - name: Brand Name
    title: Brand Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: button_group
      display: inline
    model: "@{CCAIP_MODEL}"
    explore: queue_summary
    listens_to_filters: []
    field: call_details.brand_name
  - name: Queue Name
    title: Queue Name
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: "@{CCAIP_MODEL}"
    explore: queue_summary
    listens_to_filters: []
    field: call_interactions.menu_path
