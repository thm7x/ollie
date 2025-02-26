# *** Project ***

## introduce

- Use the [Kitex](https://github.com/cloudwego/kitex/) framework
- Generating the base code for unit tests.
- Provides basic config functions
- Provides the most basic MVC code hierarchy.

## Directory structure

|  catalog   | introduce  |
|  ----  | ----  |
| conf  | Configuration files |
| main.go  | Startup file |
| handler.go  | Used for request processing return of response. Multiple RPC responses can be combined|
| kitex_gen  | kitex generated code |
| service  | The actual business logic. |

## How to run local

```shell
NAMESPACE=local air
```
