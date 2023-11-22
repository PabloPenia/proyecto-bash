# proyecto control Pizza

Programa para control de pizzerias.

# Uso del programa

Ejecutar `./pizza.sh`

## Opciones

`./pizza.sh --help` o `./pizza.sh -h` muestra la ayuda.

### Menu Principal

- **Administrar pedidos**: Permite ingresar, modificar, eliminar o marcar como
  entregado un pedido, tambien se puede ver la lista de pedidos
- **Ver combos**: Muestra la lista de combos
- **Ver clientes**: Muestra la lista de clientes
- **Resumen de ventas**: Muestra diferentes analiticas de ventas.

## Ingresar un pedido

El programa solicitara, codigo del cliente, codigo del combo y cantidad. Luego
de ingresado se puede ver en el listado.

## Modificar un pedido

Luego de ingresar el codigo del pedido, nos permite modificar el combo del
mismo.

## Cancelar un pedido

Lo elimina de la base de datos.

## Marcar como entregado

Marca los pedidos que ya se entregaron.

## Analiticas

Se pueden ver analiticas por combos, clientes y usuario que ingresa los pedidos.

## Base de datos

Todos los datos se guardan en CSV lo que lo hace mas facil para utilizar con
APIs o transformar a hojas de calculo.
