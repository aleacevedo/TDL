pragma solidity ^0.4.25;

import "./ERC20.sol";
import "./Coin.sol";

contract owned {
    constructor() public { owner = msg.sender; }
    address owner;

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}


contract SistemaDeNotas is owned{

    ERC20 private ERC20Interface;

    struct Alumno {
        string nombre;
        uint256 padron;
        uint256 grupo;
        uint256 nota;
        address direccion;
        bool registrado;
        bool notaAceptada;
    }

    struct Grupo {
        bool notaAceptada;
        uint256 notaContenido;
        uint256 notaGrupal;
        uint256[] integrantes;
    }

    mapping(uint256 => Alumno) alumnos;
    mapping(uint256 => Grupo) grupos;
    mapping(address => uint256) registros;

    address profesor;
    address nota;

    constructor () public{
        profesor = msg.sender;
        nota = address(new Coin(100000, "TDLCoin", "TDL")); 
    }
    
    function verDireccionMoneda() view returns(address){
        return nota;
    }
    
    function verDireccionContrato() view returns(address){
        return address(this);
    }
    
    
    function calcularNotaFinal(uint256 notaContenido, uint256 notaGrupal, uint256 notaIndividual) private pure returns(uint256){
        return ((notaContenido*70) + (notaGrupal * 20) + (notaIndividual * 10))/100;
    }

    function registrarAlumno(string nombre, uint256 padron) public{
        require(!alumnos[padron].registrado);
        registros[msg.sender] = padron;
        alumnos[padron].padron = padron;
        alumnos[padron].nombre = nombre;
        alumnos[padron].registrado = true;
    }

    function obtenerInformacion() public constant returns (string nombre, uint256 padron, uint256 grupo, uint256 nota){
        // Aca puede ir un memory
        Alumno memory alumnoActual = alumnos[registros[msg.sender]];
        nombre = alumnoActual.nombre;
        padron = alumnoActual.padron;
        grupo = alumnoActual.grupo;
        nota = calcularNotaFinal(grupos[alumnoActual.grupo].notaContenido, grupos[alumnoActual.grupo].notaGrupal, alumnoActual.nota);
    }

    function agregarAlGrupo(uint256 padron, uint256 numeroDeGrupo) public onlyOwner {
        alumnos[padron].grupo = numeroDeGrupo;
    }

    function calificarContenido(uint256 grupoNum, uint256 nota) public onlyOwner{
        require(!grupos[grupoNum].notaAceptada);
        grupos[grupoNum].notaContenido = nota;
    }

    function calificarGrupo(uint256 grupoNum, uint256 nota) public onlyOwner{
        require(!grupos[grupoNum].notaAceptada);
        grupos[grupoNum].notaGrupal = nota;
    }

    function calificarAlumno(uint256 padron, uint256 nota) public onlyOwner{
        require(!alumnos[padron].notaAceptada);
        alumnos[padron].nota = nota;

    }

    function aceptarNota() public returns(uint256 notaFinal, uint256 notaIndividual, uint256 notaGrupal,  uint256 notaContenido){
        require(!alumnos[registros[msg.sender]].notaAceptada);
        require(alumnos[registros[msg.sender]].nota > 0 &&
        grupos[alumnos[registros[msg.sender]].grupo].notaGrupal > 0 &&
        grupos[alumnos[registros[msg.sender]].grupo].notaContenido>0);
        notaIndividual = alumnos[registros[msg.sender]].nota;
        notaGrupal = grupos[alumnos[registros[msg.sender]].grupo].notaGrupal;
        notaContenido = grupos[alumnos[registros[msg.sender]].grupo].notaContenido;
        notaFinal = calcularNotaFinal(notaContenido, notaGrupal, notaIndividual);
        if(notaFinal>4){
            ERC20Interface = ERC20(nota);
            ERC20Interface.transfer(msg.sender,notaFinal);
            alumnos[registros[msg.sender]].notaAceptada = true;
            grupos[alumnos[registros[msg.sender]].grupo].notaAceptada = true;
        }
    }





}
