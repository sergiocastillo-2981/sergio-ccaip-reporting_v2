- dashboard: contacts_overall
  title: Contacts Overall
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: true
  description: ''
  preferred_slug: rDPufb5Nyl26wUhuTebu58
  elements:
  - title: LAB SLA% KPI
    name: LAB SLA% KPI
    model: "@{CCAIP_MODEL}"
    explore: contacts
    type: marketplace_viz_radial_gauge::radial_gauge-marketplace
    fields: [contacts.perc_in_sla]
    filters:
      contacts.brand_name: Lab
    sorts: [contacts.perc_in_sla desc 0]
    limit: 500
    column_limit: 50
    hidden_fields: []
    hidden_points_if_no: []
    show_view_names: true
    arm_length: 25
    arm_weight: 50
    spinner_length: 100
    spinner_weight: 50
    angle: 90
    cutout: 50
    range_x: 1
    range_y: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 0
    hidden_pivots: {}
    listen:
      Contact Date: contacts.contact_date
    row: 6
    col: 8
    width: 8
    height: 6
  - title: AA SLA% KPI
    name: AA SLA% KPI
    model: "@{CCAIP_MODEL}"
    explore: contacts
    type: marketplace_viz_radial_gauge::radial_gauge-marketplace
    fields: [contacts.perc_in_sla]
    filters:
      contacts.brand_name: avast
    sorts: [contacts.perc_in_sla desc 0]
    limit: 500
    column_limit: 50
    hidden_fields: []
    hidden_points_if_no: []
    show_view_names: true
    arm_length: 25
    arm_weight: 50
    spinner_length: 100
    spinner_weight: 50
    angle: 90
    cutout: 50
    range_x: 1
    range_y: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 0
    hidden_pivots: {}
    listen:
      Contact Date: contacts.contact_date
    row: 6
    col: 0
    width: 8
    height: 6
  - title: SLA %
    name: SLA %
    model: "@{CCAIP_MODEL}"
    explore: contacts
    type: marketplace_viz_radial_gauge::radial_gauge-marketplace
    fields: [contacts.perc_in_sla]
    filters:
      contacts.brand_name: ''
    sorts: [contacts.perc_in_sla desc 0]
    limit: 500
    column_limit: 50
    hidden_fields: []
    hidden_points_if_no: []
    show_view_names: true
    arm_length: 25
    arm_weight: 50
    spinner_length: 100
    spinner_weight: 50
    angle: 90
    cutout: 50
    range_x: 1
    range_y: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 0
    hidden_pivots: {}
    listen:
      Contact Date: contacts.contact_date
    row: 0
    col: 4
    width: 8
    height: 6
  - title: Overal Details
    name: Overal Details
    model: "@{CCAIP_MODEL}"
    explore: contacts
    type: table
    fields: [contacts.brand_name, contacts.selected_menu_name, contacts.count, contacts.count_handled,
      contacts.total_abandoned, contacts.perc_abandoned, contacts.perc_handled, contacts.perc_in_sla,
      contacts.avg_queue_duration_hhmmss, contacts.avg_handle_time_hhmmss, contacts.perc_transfers]
    sorts: [contacts.brand_name]
    limit: 500
    column_limit: 50
    show_view_names: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_fields: []
    hidden_points_if_no: []
    arm_length: 25
    arm_weight: 50
    spinner_length: 100
    spinner_weight: 50
    angle: 90
    cutout: 50
    range_x: 1
    range_y: 1
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    defaults_version: 1
    hidden_pivots: {}
    listen:
      Contact Date: contacts.contact_date
    row: 12
    col: 0
    width: 24
    height: 8
  filters:
  - name: Contact Date
    title: Contact Date
    type: field_filter
    default_value: 7 day
    allow_multiple_values: true
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
      options: []
    model: "@{CCAIP_MODEL}"
    explore: contacts
    listens_to_filters: []
    field: contacts.contact_date
