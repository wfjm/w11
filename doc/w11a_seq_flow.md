# w11a State Diagram Annotation

The states are 
  1. grouped by _flows_, related states are in a dashed box
  2. grouped in _classes_ by color

| Color | State Class |
| :---- | :---------- |
| blue         | idle/fetch/decode states |
| cyan         | console handling states |
| light orange | source address mode flow |
| dark orange  | destination address mode flows |
| green        | states for main opcode handling |
| red          | states for error handling |

The grey `fork_...` hexagons represent three transition groups which are 
common to the control flow of several states. There is no corresponding 
state, these symbols just help to reduce the number of transition lines 
on the flow chart.

The transitions are color coded too:

| Color | Transition Class |
| :---- | :--------------- |
| green       | normal _forward_ transition in a flow |
| blue        | i/o wait loop |
| red         | error/trap handling |
| magenta     | fatal errors to cpufail state |
| thick black | link to a `fork_...` symbol |
| black       | all other transitions |
