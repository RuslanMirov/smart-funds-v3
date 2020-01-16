// TODO shoulg get this address and BANCOR ETH address from Bancor registry
pragma solidity ^0.4.24;

import "./interfaces/PathFinderInterface.sol";
import "./interfaces/BancorNetworkInterface.sol";
import "./interfaces/IGetBancorAddressFromRegistry.sol";
import "../zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../helpers/stringToBytes32.sol";

contract GetRatioForBancorAssets {
  using stringToBytes32 for string;

  IGetBancorAddressFromRegistry public bancorRegistry;

  constructor(address _bancorRegistry) public{
    bancorRegistry = IGetBancorAddressFromRegistry(_bancorRegistry);
  }

  // Get Ratio between Bancor assets
  function getRatio(address _from, address _to, uint256 _amount) public view returns(uint256 result){
    if(_amount > 0){
      // get latest contracts
      PathFinderInterface pathFinder = PathFinderInterface(
        bancorRegistry.getBancorContractAddresByName("BancorNetworkPathFinder")
      );

      BancorNetworkInterface bancorNetwork = BancorNetworkInterface(
        bancorRegistry.getBancorContractAddresByName("BancorNetwork")
      );

      // get Bancor path array
      address[] memory path = pathFinder.generatePath(_from, _to);
      ERC20[] memory pathInERC20 = new ERC20[](path.length);

      // Convert addresses to ERC20
      for(uint i=0; i<path.length; i++){
          pathInERC20[i] = ERC20(path[i]);
      }

      // get Ratio
      ( uint256 ratio, ) = bancorNetwork.getReturnByPath(pathInERC20, _amount);
      result = ratio;
    }
    else{
      result = 0;
    }
  }
}
