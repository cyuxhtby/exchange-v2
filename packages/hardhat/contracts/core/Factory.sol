// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { LiquidityPair } from "./LiquidityPair.sol";
import { ILiquidityPair } from "../interfaces/ILiquidityPair.sol";

contract Factory {

    mapping(address token0 => mapping(address token1 => address pairContract) ) public getPair;
    address[] public allPairs;
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    
    constructor() {}

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    /// @notice uses create2 opcode for deterministic address creation, takes in (value, offset, length, salt)
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); // formal ordering of pairs
        require(token0 != address(0), 'Zero address');
        require(getPair[token0][token1] == address(0), 'Pair exists'); 
        bytes memory bytecode = type(LiquidityPair).creationCode; // factory pattern
        bytes32 salt = keccak256(abi.encodePacked(token0, token1)); // identification value for pair
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ILiquidityPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

}