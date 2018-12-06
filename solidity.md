Solidity
========

## Inicios de SOLIDITY

31 de Octubre de 2008 se publica el whitepaper de Bitcoin. El creador, Satoshi lo proponia como una forma de realizar transacciones monetarias transparentes y sin intervenciones de autoridades centralizadas, como un banco.

A medida que paso el tiempo, la gente se fue dando cuenta que se podian usar las mismas ideas de bitcoin para manejar transacciones de distinta indole, no unicamente de dinero.

En 2013, se publica el Whitepaper de Ethereum el cual proponia utilizar la blockchain para almacenar _entidades_. Finalmente el sistema salio el 30 de julio de 2015. Sin embargo no fue hasta el PdC7 que se introdujo Solidity

## Características básicas del lenguaje:

  Solidity es un lenguaje orientado a contratos, esto lo podríamos llegar pensar como un lenguaje orientado a objetos donde únicamente se puede usar un singleton, es decir una instancia única de nuestro contrato el cual seria nuestro único objeto. Fue influenciado por C++, Python y JavaScript y diseñado para correr en la Etherum Virtual Machine.

  El mismo es un lenguaje tipado estaticamente y soporta herencia, librerias y tipos complejos definidos por el usuario.

  Cada contrato que se desarrolla es compilado en codigo de bytes y luego se corre sobre la Ethereum Virtual Machine.


## Concepto de blockchain

- ### Bloques

  Bloque génesis es el primer bloque de la cadena el cual se genera cuando se  instancia el contrato por primera vez.

  Cada bloque almacena, las variables del contrato en el estado que se encontraban al generear este bloque, el hash de si mismo el cual se generea a partir de la informacion que tiene el mismo, el hash del bloque anterior.

- ### Privacidad y Transparencia

   Cada uno de los bloques pueden ser observados por cada una de las personas que forman parte de la red, lo cual le aporta un grado de transparencia muy alto a cualquier transacción que se realice. Al estar totalmente codificada, la blockchain el uso de la blockchain es anónimo y privado.

## Características avanzadas del lenguaje

## Sintaxis  
Sintaxis en solidity (info: .doc de rsk)
_explicas masomenos como se define la sintaxis y unos ejemplos basicos de eventos, GAS y contratos_

los contratos son similares a las clases en lenguajes OOP.
tienen _asignaciones_ del tipo :


-  #### State variables

  Son values que son permanentemente guardados en el contrato.
  ```
  pragma solidity ^ 0.4.0

  contract SimpleStorage {
    uint storedData ; // State variable
  }
  ```
// Types for valid state variables and Visibility and Getters

- #### Functions

  self explains > executable units of code within a contract

  ```
  pragma solidity ^ 0.4.0

  contract SimpleAuction {
    function bid() payable { //Tipo de funcion
      // ...
    }
  }
  ```
  las calls a funciones tienen distinto tipo de visibilidad respecto otros contratos, (internas, externas)


- #### Function modifiers



- #### Events

  Son interfaces con la EVM

  _Events and logs are important in Ethereum because they facilitate communication between smart contracts and their user interfaces. In traditional web development, a server response is provided in a callback to the frontend. In Ethereum, when a transaction is mined, smart contracts can emit events and write logs to the blockchain that the frontend can then process. There are different ways to address events and logs._

  ```
  pragma solidity ^ 0.4.0 ;

  contract SimpleAuction {
    event HighestBidIncreased(address bidder, uint amount); //Event

    function bid() payable {
      // ....
      HighestBidIncreased(msg.sender, msg.value); // Triggering event
    }
  }
  ```

Hay 3 casos generales para el uso de eventos y logs que hay que diferenciar :

- Para utilizar los valores del contrato

  El uso mas simple de un evento es para pasar valores devueltos por un contrato al frontend de una app

  ```
  contract ExampleContract {
    // some state variables ...
    function foo(int256 _value) returns (int256) {
      // manipulate state ...
      return _value;
    }
  }
  ```

  Si decimos que exampleContract es una instancia de ExampleContract un programador, utilizando
  *web3js* (una API de Etherum para js) podria tranquilamente guardarse el valor asignandolo a una variable

  ```
  var returnValue = exampleContract.foo.call(2);
  console.log(returnValue) // 2
  ```
  El tema esta en que cuando web3js hace el llamado no puede almacenarselo en returnValue

  ```
  var returnValue = exampleContract.foo.sendTransaction(2, {from: web3.eth.coinbase});
  console.log(returnValue) // hash de la transaccion
  ```

  El valor que tiene returnValue es el hash de la transaccion que se creo. Las transacciones no devuelven el valor automaticamente porque no son minadas al instante en la blockchain.
  Para tacklear este problema se utilizan los _eventos_

  ```
  contract ExampleContract {
    event ReturnValue(address indexed _from, int256 _value);

  function foo(int256 _value) returns (int256) {
      ReturnValue(msg.sender, _value);
      return _value;
    }
  }
  var exampleEvent = exampleContract.ReturnValue({_from: web3.eth.coinbase});
  exampleEvent.watch(function(err, result) {
    if (err) {
      console.log(err)
      return;
    }
    console.log(result.args._value)
    // Fijate que result.args. sea del tipo web3.eth.coinbase
    // display result.args._value  
    // exampleEvent.stopWatching()
  })
  exampleContract.foo.sendTransaction(2, {from: web3.eth.coinbase})
  ```
  Cuando la transaccion que llama a foo es minada, el callback dentro del contrato se triggerea.
  _en criollo, hasta que el contrato no se mina, exampleEvent.watch no se ejecuta_
  Esto permite utilizar los valores de foo.

- Para triggers asincronicos con data

  Devolver valores son casos minimos, los eventos en general son considerados triggers asincronicos de data. Cuando un contrato necesita triggerear
  al frontend, este emite un emento. Mientras el frontend esta esperando un evento, puede realizar acciones como mostrar un mensaje, etc.

- Para optimizar el almacenamiento de espacio / memoria??

  El ultimo caso es usar eventos como una forma de optimizar el almacenamiento.
  Los contratos emiten/triggerean eventos a los cuales el front responde.
  Cuando se emite un evento, el respectivo log se escribe en la blockchain.

  Los logs son una forma de almacenamiento mucho mas barata en terminos de _GAS_, comparado a el contract storage.
  *logs* : 8 gas / byte
  *contract storage* : 20000 gas / 32bytes (625/byte)
  El tema esta en que los logs no son accesibles desde cualquier contrato.

**Entonces por que usarias logs?**

Hay situaciones donde amerita, por ejemplo, necesitas guardar historical data rendereada por el front.

*Otro ejemplo:*
Una transferencia quizas necesite mostrarle al usuario todos los depositos que se realizaron en la transferencia. Entonces en vez de guardar estos en el contrato (utilizando contract storage), es mucho mas barato guardarlos en logs.
Esto es posible ya que una transferencia unicamente necesita saber el estado del balance de un usuario. Pero no necesita saber del record historico

```
contract CryptoExchange {
  event Deposit(uint256 indexed _market, address indexed _sender, uint256 _amount, uint256 _time);

function deposit(uint256 _amount, uint256 _market) returns (int256) {
    // deposita, actualiza el user’s balance, etc
    Deposit(_market, msg.sender, _amount, now);
}
```
Supongamos que queremos actualizar la UI mientras el usuario realiza depositos.

Este es un ejemplo utilizando un evento (Deposit), como un trigger asincronico con data: (_ market, msg.sender, _ amount, now).

Asumiendo que cryptoExContract es una instancia de CryptoExchange:

```
var depositEvent = cryptoExContract.Deposit({_sender: userAddress});
depositEvent.watch(function(err, result) {
  if (err) {
    console.log(err)
    return;
  }
  // appendea los detalles de result.args a la UI
})
```

Mejorar la eficiencia de obtener todos los eventos para un usuario es la razon por la cual el parametro _ sender es indexado:
`event Deposit(uint256 indexed _market, address indexed _sender, uint256 _amount, uint256 _time)`

Por default, escuchar eventos solo empieza cuando el evento es instanciado.
Cuando la UI esta cargando en primera instancia, no hay depositos a los cuales appendear.
Para ello necesitamos obtener los eventos desde el block 0, y esto lo hacemos incluyendo un `fromBlock` al evento.

```
var depositEventAll = cryptoExContract.Deposit({_sender: userAddress}, {fromBlock: 0, toBlock: 'latest'});
depositEventAll.watch(function(err, result) {
  if (err) {
    console.log(err)
    return;
  }
  // appendea los detalles de result.args a la UI
})
```
Cuando se termina de renderear la UI, se debe llamar a `depositEventAll.stopWatching()`.

- Extra:

  Se pueden indexar hasta 3 parametros. Por ejemplo, un token standart tiene:
  `event Transfer(address indexed _from, address indexed _to, uint256 _value)`
  Esto significa que el frontend puede esperar a token transfers que son:

  - Enviado por la address `tokenContract.Transfer({_from: senderAddress})`

  - O recibido por una address `tokenContract.Transfer({_to: receiverAddress})`

  - O enviado de una address a una address especifica
    `tokenContract.Transfer({_from: senderAddress, _to: receiverAddress})`

- Wrap up de eventos:

  Tres ejemplos de casos con eventos, el primero, usar un evento para obtener un value de un contrato invocado por sendTransaction().
  Otro, utilizar un trigger asincronico con data, que puede notificar a un observador como la UI.
  Y por ultimo, utilizar un evento para escribir logs en una blockchain es mucho mas barato que utilizar contract storage.


- #### Struct types

  Son custom defined types que pueden agrupar distintos tipos de variables

  ```
  pragma solidity ^0.4.0;

  contract Ballot {
    struct Voter {
      uint weight;
      bool voted;
      address delegate;
      uint vote;
    }
  }
  ```
- #### Enum types
Los enums pueden ser para crear custom types finitos de un set de valores

  ```
  pragma solidity ^ 0.4.0;

  contract Purchase {
    enum State {Create, Locked, Inactive} // Enum
  }
  ```

- ##### Wrap up de sintaxis

  **Contrato ejemplo :**

  ```
  pragma solidity ^ 0.4.4;

  contract StoreSomeData{
    //el estado del contrato esta representado
    //por el valor de toda su data en un tiempo

    uint storedData;

    //setter
    function set(uint i){
      storedData = i;
    }

    function get() constant returns(uint){
      return storedData;
    }
  }
  ```

  - ** Cosas a apuntar del ejemplo: **

    - storedData es del tipo uint y por defecto es privado (no se puede acceder desde afuera)
    - Si no se agrega el private modifier todos los metodos son accesibles desde afuera
    - el getter utiliza el constant modifier, que indica que la funcion no modifica el estado del contrato.
    - Si implementamos algo que cambiase el contrato (y la blockchain), eso nos va a costar *GAS* y requiere de una transaccion.

  ** Ejemplo mas complejo: **

  Otro uso interesante de los smart contracts es almacenar data para siempre sin la posibilidad de cambiar.

  Situacion: quiero registrar algo que cree, ej: una imagen. Puedo utilizar algun software para obtener el SHA256 hash de la imagen, guardar este valor en el Smart Contract, asi este hash va a perdurar para siempre sin la posibilidad de que alguien lo modifique. En el caso de que alguien copia mi imagen, puedo demostrar que yo hice el original y que el hash fue registrado mucho tiempo antes de que lo copiaran.  

  Para implementar esto, armamos otro contrato:

  ```
  pragma solidity ^ 0.4.4;

  contrat StoreHash {
    // guarda el address del creador del contrato.
    address creator;
    bytes32 storedHash;
    //el creador del contrato manda el hash y se guarda para siempre

    function StoreHash (bytes32 hash){
      creator = msg.sender;
      storedHash = hash;
    }

    function getHash() constant returns (bytes32) {
      return storedHash;
    }

    function kill(){
      if (msg.sender == creator)
        suicide(creator); //explicar que es suicide() y que solo
    }                     // puede ser llamado x el creador

  }
  ```

  Simple, guardamos un hash de 32 bytes mientras construimos el contrato, y no puede ser modificado, solo queriado.

  Cada transaccion debe especificar una cantidad de *GAS* que espera consumir (llamada _startgas_), y el fee que espera a pagar por unidad de gas (_gasprice_). En el comienzo de cada ejecucion, _startgas_ x _gasprice_ SBTC son removidas de la transaccion de quien envia. (sender)

  **Ejemplo mas complejo:**

  Hay que comentar bien este codigo

  ```
  pragma solidity ^ 0.4.6;

  contract GanadorDeProjectos {
    uint minimumEntryFee;
    uint public deadlineProjects;
    uint public deadlineCampaign;
    uint public winningFunds;
    address public winningAddress;

    struct Project {
      address addr;
      string name;
      string url;
      uint funds;
      bool initialized;
    }

    mapping (address => Project) projects; //Hasheo los projectos
    address[] public projectAddresses;
    uint public numberofProjects;

    event ProjectSubmitted(address adrr, string name, string url, bool initialized);
    event ProjectSupported(address addr, uint amount);
    event PayedOutTo(address addr, uint winningFunds);

    function GanadorProjectos(uint _minimumEntryFee, uint _durationProjects, uint _durationCampaign) public {
        if (_durationCampaign <= _durationProjects){
          throw;
        }
        minimumEntryFee = _minimumEntryFee;
        deadlineProjects = now + _durationProjects * 1 seconds;
        deadlineCampaign = now + _durationCampaign * 1 seconds;
        winningAddress = msg.sender;
        winningFunds = 0;
    }

    function submitProject(string name, string url payable public returns(bool success) {
      if (msg.value < minimumEntryFee) {
        throw;
      }

      if (now > deadlineProjects) {
        throw;
      }

      if (!projects[msg.sender].initialized){
        projects[msg.sender] = Project(msg.sender, name, url, 0, true);
        projectAddresses.push(msg.sender);
        numberOfProjects = projectAddresses.length;
        ProjectSubmitted(msg.sender, name, url, projects[msg.sender].initialized);
        return true
      }
      return false;
    }

    function supportProject(addres addr) payable public returns (bool success){
      if(msg.value <= 0) {
        throw;
      }

      if(now > deadlineCampaign || now <= deadlineProject ) {
        throw;
      }

      if(!project[addr].initialized){
        throw;
      }

      projects[addr].funds += msg.value;

      if(project[addr].funds > winningFunds) {
        winningAddress = addr;
        winningFunds = projects[addr].funds;
      }

      ProjectSupported(addr,msg.value);
      return true;
    }

    function getProjectInfo(address addr) public constant returns (string name, string url, uint funds) {
      var project = projects [addr];

      if (!project.initialized) {
        throw;
      }

      return (project.name, project.url, project.funds);
    }

    function finish (){
      if (now >= deadlineCampaign) {
        PayedOutTo(winningAddress, winningFunds);
        selfdestruct(winningAddress); //Kill al contrato
      }
    }
  }
  ```

## Manejo de memoria y CPU en blockchain

  Mostrar como optimizar el gas de un programa. MOstrar dos programas que hagan lo mismo pero que uno consuma mas que el otro.
  https://medium.com/joyso/solidity-save-gas-in-smart-contract-3d9f20626ea4

  Ethereum corre sobre la EVM. La misma es _casi_ Turing Completa. Tecnicamente puede computar cualquier cosa que se le pida, sin embargo la capacidad de computo esta atada por 'Gas'.

  El Gas
  Cada transacción que se lleva a cabo mediante los SmartContracts consumen ‘Gas’.
  El Gas no es ni mas ni menos que el gasto computacional de procesar una transacción o contrato inteligente en la red
  El Gas tiene un precio, que es la cantidad de ether que un usuario esta dispuesto a gastar para realizar una transaccion, en general medido en 'Wei', la minima division de Eth.

  Para realizar una trnasaccion en la red de eth, un individuo debe indicar el limite maximo de gas y el precio del gas asociado a la transaccion. Si no se posee el gas necesario, se considerara una transaccion invalida.

  Esto evita que se den bucles infinitos los cuales colapsarían el sistema (Ejemplo que muestre como evitaria un bucle infinito)

- #### CPU
  https://medium.com/@jeff.ethereum/optimising-the-ethereum-virtual-machine-58457e61ca15

  "The network consists of nodes, which are ordinary computers running a program called a client. Anyone can run a node. When the client runs for the first time, it creates an EVM on the computer, which is a sandboxed environment where the state will be stored and includes the virtual processor which will execute transactions (turn EVM bytecode into machine instructions that alter the state). It initializes the state to the Genesis state.

  The nodes send new (unmined) transactions to the rest of the network. The miners collect these then the lucky miner adds as many as they can/want to their new block, which they send to the rest of the network. The nodes receive a new block, verify its validity, and then execute all the transactions in it on their EVM."

- #### *MEMORIA*

  Hay tres tipos distintos de memoria en solidity:

  https://ethereum.stackexchange.com/questions/23720/usage-of-memory-storage-and-stack-areas-in-evm?noredirect=1&lq=1

  - ##### Storage:

    Es el mas caro de los tres, tiene un costo de 20000 _gas_ para setear un espacio de memoria y de 5000 _gas_ para cambiar el valor. Esta memeoria es la que se guarda dentro del bloque de la block chain, y por eso su elevado costo. La idea de esta memoria es guardar valores que se quieren mantener constantes entre las distintas ejecuciones del contrato.

    ```
    string[] storage newItems = items;
    ```

  - ##### Memory:

   Es relativamente mas barata que el storage, cuesta 3 gas para leer y escribir, y un poco mas de gas para expandir la memoria. El problema es que el costo aumenta de forma cuadratica cuando cuando se requiere mas memoria. Los costos anteriores era para guardar kbs mientras que para un mb de memoria constaria unos millones de gas. A diferencia de el storage, esta memoria es volatil, solo existe en tiempo de ejecucion del contrato. La opcion de usar _memory_ crea una copy en lugar de un puntero, de esta menera no se afecta la variable original.

    ```
    string[] memory newItems = items;
    ```

  - ##### Stack:

    Tiene un costo similar al memory, tiene un maximo de 1024 items, pero solo los primeros 16 bloques son accesibles con facilidad. Si un contrato se queda sin memoria en el stack este fallara. Al ser parte fundamental de la ejecucion del contrato lo mejor es no tocarlo y dejar que el compilador se encargue de guardar lo que necesita dentro del stack.


*El cliente descarga todos los nodos de la blockchain ? Corroborar
Como hace para que no se haga enorme? Gas?
Habria que ver que onda porque derepente un cliente podria explotar porque no le da el hardware*


## Concurrencia

La concurrencia en solidity no esta implementada ya que al ser un programa que corre sobre una blockchain no
puede usarse fácilmente ya que es posible que se generen conflictos en el uso de MEMORIA

Sin embargo, en el ultimo tiempo se ha investigado y se ha escrito un paper con la posible
implementación de la concurrencia sobre una blockchain. Cabe destacar que esto no seria
propio del lenguaje si no que se implementaría a nivel de blockchain.

La idea de este paper es que los mineros ejecuten los diferentes contratos en paralelos
de forma especulativa. En caso de que se produzca un conflicto solo sigue ejecutandose uno de los contratos y lo cambios generados por el resto se deshacen. Una vez que termina de ejecutarse se vuelven a ejecutar los contratos
que se deshicieran

Una vez que el nuevo bloque es creado, es necesario que los validadores chequen la creación, ejecutando los contratos que se ejecutaron anteriormente en el orden que fueron ejecutados por el minero. Para esto es necesario que los mineros
produzcan y publiquen información extra, recolectada cuando  se ejecutaron los contratos por primera vez.

De esta forma se genera una hoja de ruta para que los validadores ejecuten los contratos en paralelo cuando es posible y  en el orden correcto cuando no lo es.

## Problemas especificos de Etherum
- #### Actualizacion del codigo del contract

  Una vez que el contrato esta en la blockchain, es imposible de modificar. Ciertos parametros pueden ser modificados via el codigo original por supuesto, pero no es posible realizar acciones que no esuvieran contempladas al momento de incluir el contrato en la blockchain.

  Un metodo para actualizar el codigo del contrato y ampliar la funcionalidad, es utilizar un metodo de versionado. Podria usarse un contrato _wrapper_ con una referencia a la ultima version del contrato que redireccione los llamados.

  Otra forma de hacerlo es incluyendo codigo propio de Solidity, usando CALLCODE para invocar codigo escrito en una direccion especificable y actualizable. De esta forma, la informacion de usuario persiste entre versiones.

  Desde la actualizacion de Homestead, existe una <funcion> DELEGATECALL. Esto permite refireccionar los llamaods a un contrato distinto , manteniendo `msg.sender` y todo el storage.

  Por ejemplo, podriamos tener un contrato que mantiene la direccion y el almacenamiento, pero redirecciona los llamados a otra direccion almacenada en una variable:

    ```
    contract Relay {
        address public currentVersion;
        address public owner;

        function Relay(address initAddr){
            currentVersion = initAddr;
            owner = msg.sender;
        }

        function update(address newAddress){
            if(msg.sender != owner) throw;
            currentVersion = newAddress;
        }

        function(){
            if(!currentVersion.delegatecall(msg.data)) throw;
        }
    }
    ```






## Comparacion de las EOS

EOS es le rival por defecto de Ethereum, la plataforma sobre la cual corren los contratos desarrollados en Solidity, es decir EOS es una plataforma, no un lenguaje, sobre la cual corren contratos los cuales son escritos en C++ o cualquier otro "WebAssembly language". Es decir que si queremos comparar con EOS, lo que debemos comparar es Ethereum y no Solidity. La diferencia entre estas dos plataformas se encuentra en como cada una de ellas encara el trilema de la escalabilidad.

Este trilema es sobre la seguridad, la descentralizacion y la escalabilidad. Y en estas dos ultimas partes es donde yacen las diferencias, mientras que Ethereum pone por sobre todas las cosas la descentralizacion, EOS favorece la escalabilidad.


## SandBoxing

La etherum virtual machine se encuentra completamente aislada lo que significa que el codigo corre dentro de la virtual machine y no tiene acceso a la red, ni al sistema de archivos ni a ningun otro proceso. Esto le suma un cierto nivel de seguridad a los contratos que corran sobre la virtual machine. A pesar de que ir contra la filosofia del blockchain existe una herramienta llamada oraclize la cual podríamos visualizarla como un puente al exterior ya que a través de esta podemos hacer llamados a diferentes paginas y apis como asi también a otras librerias.

## Tipos de variables no convencionales

- ### Address

 El tipo address es un valor de 160 bits que no permite operaciones aritmeticas, y debe ser usado para almazenar dirrecciones de contratos o pares de claves pertenecientes a presonas externas.

- ### Mapping

  Este tipo mapea un tipo de variables a otro tipo de variables, es decir por ejemplo mapping(address => uing) mapea direcciones a enteros sin signo. Este tipo de variable puede ser visto como una tabla de hash inicializada de forma tal que cada clave existe y es mapeada a un valor cuya representacion en bytes es todo ceros


## Variables globales magicas

- ### msg

  Contiene propiedades que permiten el acceso a la blockchain, por ejemplo msg.sender es siempre la direccion desde donde se origina la llamada a la funcion actual.

- ### block

  Contiene informacion del bloque actual, por ejemplo block.gaslimit es el limite de gas que tiene el bloque actual

- ### tx

  Contiene informacion de la transaccion, por ejemplo tx.gasprice es el precio en gas de la transaccion.

## Estadisticas

  - En 2013 Ethereum fue descripta por primera vez con la meta de desarrollar aplicaciones descentralizadas

  - En 2016 ethereum podia procesar 25 trasaccion por segundo lo que es muy poco en contra posicion con los 45 mil pagos por segundo que maneja visa por ejemplo.

  - En febrero de 2018 habia 27 mil nodos en la red principal de Ethereum

  - El precio de 1 Ether es aproximadamente 200 dolares

Faltantes:
- compilado/interpretado:
- control de flujos
- tdas
- parámetros o cualquier concepto básico particular que soporte el lenguaje
- Cosas a mirar : Lazy / Threads / Puertos / ADTS / Wrappers / Estado de contratos
- ## Estadísticas de uso del lenguaje, frameworks y la evolución en los últimos años.
- ## Comparación otros lenguajes similare
- ## Se mencionan casos reales indicando el motivo por el cuual se cree o se sabe que se usa el lenguaje
