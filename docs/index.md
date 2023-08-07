# Título da minha página

Esta é uma demonstração de como poderemos utilizar o markdown.
[Este é um link](google.com)

- Esta é uma lista:
	- Minha lista 1

### RDI $US Values
Esta é uma demonstração de como poderemos utilizar o markdown.

```vegalite
{
  "schema-url": "assets/charts/lines.json"
}
```

### RDI %Growth Values
Esta é uma demonstração de como poderemos utilizar o markdown.

```vegalite
{
  "schema-url": "assets/charts/growth.json"
}
```

### RDI Cumulative %Growth Values
Esta é uma demonstração de como poderemos utilizar o markdown.

```vegalite
{
  "schema-url": "assets/charts/cumgrowth.json"
}
```

```python
{
  import pandas as pd

# Read the data from CSV file
df_data = pd.read_csv("assets/charts/data/df_data.csv")

# Sort the data by the "date" field
df_data = df_data.sort_values(by="date")

# Calculate cumulative growth for each group (assuming "symbol" represents groups)
df_data["cumulative_growth"] = df_data.groupby("symbol")["value"].cumsum()

# Save the preprocessed data to a new CSV file
df_data.to_csv("assets/charts/data/df_data_cumulative.csv", index=False)

}
```

```vegalite
{
  "schema-url": "assets/charts/cumgrowth2.json"
}
```