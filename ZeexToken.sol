// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

import "https://github.com/iquecode/BEP20_Token/blob/main/lib/BEP20Token.sol";

contract CustomToken is BEP20Token {

  struct Lock {
    address wallet;
    uint256[] lockAmount;
    uint256[] unLockTimestamp;
  }
  mapping (address => Lock) internal _locks;

  event setLockEvent(address indexed wallet, uint256 lockAmount, uint256 unLockTimestamp);

  constructor() {
    _name = "Teste 7";
    _symbol = "TT7";
    _decimals = 6;
    _totalSupply = 10000 * 10 ** 6;
    _balances[msg.sender] = _totalSupply;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setLock(address wallet, uint256 lockAmount, uint256 unLockTimestamp) external onlyOwner {
    //verificar se encontra wallet -endereço- no mapping
    if (_locks[wallet].lockAmount.length > 0) {
      //caso encontre, incluir essa trava como novo elemento na lista de indice mapeado no _idlistOfListLocks
      _locks[wallet].lockAmount.push(lockAmount);
      _locks[wallet].unLockTimestamp.push(unLockTimestamp);
    }
    else {
      //caso não encontre, incluir nova lista em _listOfListLocks e criar o mapemaneto em mapping
      _locks[wallet].lockAmount      = [lockAmount];
      _locks[wallet].unLockTimestamp = [unLockTimestamp];
    } 
    emit setLockEvent( wallet, lockAmount, unLockTimestamp);
  }

  function _transfer(address sender, address recipient, uint256 amount) internal override {
    if (_locks[sender].lockAmount.length > 0) {
      require(sender != address(0), "BEP20: transfer from the zero address");
      require(recipient != address(0), "BEP20: transfer to the zero address");
      uint256 _actual = block.timestamp;
      uint256 _lockedAmount = 0;

      for (uint256 index = 0; index < _locks[sender].lockAmount.length; index++) {
        if (_locks[sender].unLockTimestamp[index] > _actual) {
          _lockedAmount += _locks[sender].lockAmount[index];
        }
      }

      uint256 avaliable = _balances[sender] - _lockedAmount; 
      require(avaliable >= amount, "BEP20: transfer amount exceeds free balance"); 
       _balances[recipient] += (amount);
      emit Transfer(sender, recipient, amount);
    }  
  }

  
}