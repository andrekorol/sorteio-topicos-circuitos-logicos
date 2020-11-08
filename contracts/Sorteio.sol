// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Sorteio is VRFConsumerBase, Ownable {
    bytes32 internal keyHash;
    uint256 internal fee;

    uint256[] private numbers = [
        5512988336480,
        5512988549655,
        5512981945083,
        5512987085068,
        5512988145889,
        5512997559818
    ];

    string[6] public topics = [
        "Historia do CMOS",
        "Configuracoes CMOS (Comandos)",
        "Dissipacao (Dinamica e Estatica)",
        "Parametros Eletricos Estaticos",
        "CMOS Analogico (Aplicacoes, etc)",
        "CMOS em circuitos RF"
    ];

    uint8 private topicIndex;

    uint256 public randomResult;

    event TopicoSorteado(uint256 numeroTelefone, string topicoSorteado);

    /**
     * Constructor inherits VRFConsumerBase
     *
     * Network: Rinkeby
     * Chainlink VRF Coordinator address: 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B
     * LINK token address:                0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * Key Hash: 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
     */
    constructor()
        public
        VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709 // LINK Token
        )
    {
        keyHash = bytes32(
            0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311
        );
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    /**
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed)
        public
        onlyOwner
        returns (bytes32 requestId)
    {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness;

        uint256 randomIndex = randomResult % numbers.length;
        uint256 selectedNumber = numbers[randomIndex];

        emit TopicoSorteado(selectedNumber, topics[topicIndex]);

        // Delete the selectedNumber from the array
        numbers[randomIndex] = numbers[numbers.length - 1];
        numbers.pop();

        topicIndex++;
    }

    function sorteio(uint256[] memory userProvidedSeeds) public onlyOwner {
        for (uint256 i = 0; i < userProvidedSeeds.length; i++) {
            getRandomNumber(userProvidedSeeds[i]);
        }
    }
}
