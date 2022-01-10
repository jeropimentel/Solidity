//SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

// ------------------------------
// CANDIDATO / EDAD /  ID
// ------------------------------
// toni  / 20 /       1234X
// alberto / 23 /     54321T
// joan / 21 /        98756P
// javier / 19 /      56789W


contract votacion {
    
    //direccion del propietario
    address public owner;
    
    //constructor
    constructor() public {
        owner = msg.sender;
    }
    // relacion entre hash y nombre del candidato 
    mapping (string=>bytes32) ID_Candidato;

    // relacion nombre del candidato y el nro votos
    mapping(string => uint) votos_Candidato;

    // lista para almacenar los nombres de los candidatos
    string[] candidatos;

    //lista de hashes de la identida de los votantes
    bytes32 [] votantes;

    // cualquier persona pueda usar esta funcion para presentarse a las elecciones
    function Representar(string memory _nombrePersona, uint _edadPersona, string memory _idPersona) public{
        
        // hash de los datos del candidato
        bytes32  hash_Candidato = keccak256(abi.encodePacked(_nombrePersona, _edadPersona, _idPersona));
        
        //Almacenar el hash de los datos del candidato que están ligados a su nombre
        ID_Candidato[_nombrePersona] = hash_Candidato;

        //actualizar la lista de candidatos usando push para aniadir valores al array
        candidatos.push(_nombrePersona); 
        
    }

    function verCandidatos() public view returns(string[] memory){
        return candidatos;
    }

    // funcion para votar
    function Votar(string memory _candidato) public{
        // hash de la persona que ejecuta la funcion
        bytes32 hash_Votante = keccak256(abi.encodePacked(msg.sender));
        // verificar si el votante ha votado o no
        for(uint i=0; i<votantes.length;i++){
            require(votantes[i]!=hash_Votante, "Ya has votado previamente!");
        }
        // almacenamos el hash del votante dentro del array
        votantes.push(hash_Votante);
        // aniadir un voto al candidato seleccionado
        votos_Candidato[_candidato] ++;
    }
    //dado el nombre de un candidato nos devuelve el nro de votos que tiene
    function VerVotos(string memory _candidato) public view  returns(uint){
        //devolviendo el nro de votos del candidato _candidato
        return votos_Candidato[_candidato];
    }

    //funcion auxiliar para pasar uint a string
    function uint2str(uint _i) internal pure returns(string memory _uintAsString){
        if (_i == 0){
            return "0";
        }
        uint j = _i;
        uint len;
        while(j!=0){
            len++;
            j/= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len -1;
        while(_i != 0){
            bstr[k--] = byte(uint8(48+_i%10));
            _i /= 10;
        }
        return string(bstr);
    }



    // ver votos de cada uno de los candidatos
    function VerResultados() public view returns(string memory){
        //guardamos en una variable string los candidatos con sus respectivos votos
        string memory resultados = "";

        //recorremos el array de datos para actualizar el string resultados
        for(uint i=0; i<candidatos.length; i++){
            //actualizamos el string resultados - aniadimos el candidato que ocupa la posicion "i"
            resultados = string(abi.encodePacked(resultados,"(",candidatos[i],", ", uint2str(VerVotos(candidatos[i])),")---"));
        }
        //devolvemos los resultados
        return resultados;
    }
    // proporcionar el nombre del candidato ganador
    function Ganador() public view returns(string memory){

        //la variable ganador va a contener el nombre del candidato ganador
        string memory ganador = candidatos[0];
        //flag para situacion de empate- comparamos si el ganador ha sido superado por otro candidato 
        bool flag;

        //recorrer el array de candidatos con un nro mayor de votos
        for(uint i=1; i<candidatos.length;i++){
            
            if(votos_Candidato[ganador] < votos_Candidato[candidatos[i]]){
                ganador = candidatos[i];
                flag = false;
            }else{
                if(votos_Candidato[ganador] == votos_Candidato[candidatos[i]]){
                flag = true;
                }
            }
        }
        if(flag==true){
            ganador = "Hay un empate entre los candidatos!";
        }
        return ganador;

    }

}
