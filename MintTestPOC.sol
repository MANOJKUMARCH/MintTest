pragma solidity >=0.5.0 <0.7.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/// @author Manoj Kumar Ch
/// @title Minting ERC20 Sample
contract MintTest is ERC20, Ownable{
    
    mapping(address => bool) minter;
    
    event MintRequest(address minter, address account, uint supply);
    event MintRequestStatus(address minter, address account, uint supply, bool status);
    
    modifier onlyMinter(){
        require(minter[msg.sender] == true, "Caller is not minter");
        _;
    }
    
    modifier validAddress(address _account){
        require(_account != address(0), "Address cannot be 0 address");
        _;
    }
    
    constructor(uint256 initialSupply) ERC20("MintTest", "MNT") public {
                minter[msg.sender] = true;
                _mint(msg.sender, initialSupply);
    }
    
    /// Funtion to add a minter to the network to mint MNT tokens
    /// @param _minter - address of the minter
    /// @dev an owner can add a minter to the network. Minter cannot be a zero address.
    function addMinter(address _minter) public onlyOwner validAddress(_minter){
        minter[_minter] = true;
    }
    
    /// Function for minter to place minting request
    /// @param _account - address of the account to which tokens to be minted
    /// @param _supply - total supply of the tokens for this request
    /// @dev a minter to place a minting request to mint the required number of tokens to the given account. 
    function mintRequest(address _account, uint _supply) public onlyMinter validAddress(_account){
        emit MintRequest(msg.sender,_account, _supply);
    }
    
    /// Function for contract owner to approve the mint request
    /// @param _account - address of the account to which tokens to be minted
    /// @param _supply - total supply of the tokens for this request
    /// @param _minter - minter address who raised the minting request
    /// @param _approval - approval given by the owner for the minting request
    /// @dev Owner to approve the minting request and the code verifies if the requested minter is a valid
    function approveMint(address _minter, address _account, uint _supply, bool _approval) public onlyOwner{
        if(_approval){
            bool isMinter = verifyMinter(_minter);
            if(isMinter){
                _mint(_account, _supply);
                emit MintRequestStatus(_minter, _account, _supply, true);
            }else{
                emit MintRequestStatus(_minter, _account, _supply, false);
            }
        }else{
            emit MintRequestStatus(_minter, _account, _supply, false);
        }
    }
    
    /// Function to chck if the given minter is valid
    /// @param _minter - minter address
    /// @dev returns a bool value based on the minter check
    function verifyMinter(address _minter) internal view validAddress(_minter) returns(bool _isValidMinter){
        return minter[_minter];
    }
    
}