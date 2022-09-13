// Contrato que emitira tokens para hacer STAKING
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract StellarToken {

    //Declaraciones
    string public name = "Stellar Token";
    string public symbol = "STE";
    uint256 public totalSupply = 1000000000000000000000000; //24 ceros | 1 millon de tokens
    uint public decimals = 18; // Establece el numero de decimales que puede tener. 24 ceros - 18 = 6 ceros = 1 millon

    //Evento para la transferencia de tokens de un usuario
    //Emitira un registro en la blockchain
    event Transfer (
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    //Evento para la aprobacion de un operador.
    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    //Estructura de datos
    mapping(address => uint256) public balanceOf; //Gestion de balance.
    mapping(address => mapping(address => uint)) public allowence; //Cantidad que un spender gestione sobre neustros tokens

    //Constructor -> Asignara todos los tokens que se cree al owner de este smartContract.
    constructor(){
        balanceOf[msg.sender] = totalSupply;
    }

    //Transferencia de tokens de un usuario
    function transfer(address _to, uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    //Aprobacion de una cantidad para ser gastada por un operador
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowence[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //Trasferencia de tokens especificando el emisor
    //Owner (20 tokens) => operador (5 tokens)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_value <= balanceOf[_from]);
        require(_value <= allowence[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowence[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

}