# Título da minha página

Esta é uma demonstração de como poderemos utilizar o markdown.
[Este é um link](google.com)

- Esta é uma lista:
	- Minha lista 1
	- Minha lista 1
	- Minha lista 3


### Um subtítulo

Esta é uma demonstração de como poderemos utilizar o markdown.
Esta é uma demonstração de como poderemos utilizar o markdown.
Esta é uma demonstração de como poderemos utilizar o markdown.

### Outro subtítulo

Esta é uma demonstração de como poderemos utilizar o markdown.
Esta é uma demonstração de como poderemos utilizar o markdown.
Esta é uma demonstração de como poderemos utilizar o markdown.

```vegalite
{
  "description": "A simple bar chart with embedded data.",
  "data": {
    "values": [
      {"a": "A", "b": 28}, {"a": "B", "b": 55}, {"a": "C", "b": 43},
      {"a": "D", "b": 91}, {"a": "E", "b": 81}, {"a": "F", "b": 53},
      {"a": "G", "b": 19}, {"a": "H", "b": 87}, {"a": "I", "b": 52}
    ]
  },
  "mark": {"type": "bar", "tooltip": true},
  "encoding": {
    "x": {"field": "a", "type": "nominal", "axis": {"labelAngle": 0}},
    "y": {"field": "b", "type": "quantitative"}
  }
}
```