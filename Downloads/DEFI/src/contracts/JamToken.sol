//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


contract JamToken {

    //Declaraciones
    string public name = "JAM Token";
    string public symbol = "JAM";
    uint256 public totalSupply = 1000000000000000000000000; //24 ceros | 1 millon de tokens
    uint public decimals = 18; // Establece el numero de decimales que puede tener. 24 ceros - 18 = 6 ceros = 1 millon
    //1**18 = 1 TOKEN, osea 10000000000000000 1 + 18 ceros

    //Evento para la transferencia de tokens de un usuario
    //Los eventos sirven para Emitir un registro en la blockchain
    event Transfer (
        address indexed _from, //El indexed es para que cuando filtremos lo encontremos de mas sencilla(por esa informacion)
        address indexed _to,
        uint256 _value
    );

    //Evento para la aprobacion de un operador.
    //El approval es para la persona, para aprovar a que la persona maneje nuestros tokens.
    //Operacion que emitira un orden cuando se realiza una operacion para que alguien maneje nuestros tokens
    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    //Estructura de datos
    mapping(address => uint256) public balanceOf; //Gestion de balance.
    mapping(address => mapping(address => uint)) public allowence; //Cantidad que un spender gestione sobre neustros tokens
    //Nos dira cuantos tokens tiene el spender para gastar de el owner. El owner puede tener varios spender, por eso es un mapping dentro de otro.


    //Constructor -> Asignara todos los tokens que se cree al owner de este smartContract.
    constructor(){
        balanceOf[msg.sender] = totalSupply;
    }
    //Cuando apretemos el boton en Deploy, el boton esta dando acceso al owner a asignarle los supply.

    //Transferencia de tokens de un usuario
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value); //Comprobar que la persona que clikea ahi tiene tantos tokens como quiere enviar
        balanceOf[msg.sender] -= _value; //Debe decrementar tantos tokens como quiere enviar
        balanceOf[_to] += _value; // El receptor va a aumentar esos tokens
        emit Transfer(msg.sender, _to, _value); //Enviamos un evento de transferencia con el emisor, receptor y value
        return true;//Si toda la fn fue existosa, enviamos el true.
    }

    //Aprobacion de una cantidad para ser gastada por un operador
    //Da permiso el owner a el spender para gastar esos tokens.
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowence[msg.sender][_spender] = _value; //
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //Trasferencia de tokens especificando el emisor
    // Esta funcion nos va a permitir enviar tokens de otra persona 
    //Owner (20 tokens) => operador (5 tokens)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_value <= balanceOf[_from]);//El balance de esa persona esta disponible
        require(_value <= allowence[_from][msg.sender]);/*Queremos comprobar si estos tokens que vienen
        de un owner a un emisor, esta asignados correctamente asi la persona los puede enviar*/
        balanceOf[_from] -= _value; //Decrementamos el emisor
        balanceOf[_to] += _value; //Incrementamos el receptor
        allowence[_from][msg.sender] -= _value; //Decrementamos el operador que puede operar, por ende, el owner(_from) tiene 15 tokens por darle 5 al operador.
        emit Transfer(_from, _to, _value);
        return true;
    }

}