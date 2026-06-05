import great_expectations as gx

context = gx.get_context()
datasource = context.get_datasource("olist_snowflake")
connector = datasource._data_connectors["default_inferred_data_connector_name"]
print(connector.get_available_data_asset_names())

# for testing purposes