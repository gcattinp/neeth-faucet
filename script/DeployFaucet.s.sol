// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Faucet} from "../src/Faucet.sol";

contract DeployFaucet is Script {
    function run() external returns (Faucet) {
      vm.startBroadcast();
      Faucet faucet = new Faucet();
      console.log("Faucet deployed at:", address(faucet));
      vm.stopBroadcast();
      return faucet;
    }
}
