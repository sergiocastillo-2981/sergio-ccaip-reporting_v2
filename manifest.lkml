project_name: "sergio_ccaip_reporting"
#lookml project


constant: CONNECTION_NAME {
  value: "sergio_ccaip_reporting"
  export: override_optional
}


constant: DATASET {
  value: "sergio_ccaip_reporting"
  export: override_optional
}

constant: PROJECT_NAME
{
  #Project where the DATASET resides in BIGQUERY
  value: "ccaip-reporting-lab"
  export: override_optional
}
