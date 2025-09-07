// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact contact@cheerbitcoin.org
contract CheerBitcoin is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
   
    uint256 public constant maxSupply = 2100000000 * (10 ** 18);
    uint256 public maxTransactionAmount; // New variable to store the max transaction amount

    mapping(address => bool) private _blacklisted;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, uint256 initialMaxTransactionAmount) public initializer {
        __ERC20_init("CheerBitcoin", "CHEER");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        maxTransactionAmount = initialMaxTransactionAmount; // Initialize maxTransactionAmount
    }

    function setMaxTransactionAmount(uint256 _maxTransactionAmount) public onlyOwner {
        maxTransactionAmount = _maxTransactionAmount;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= maxSupply, "Max supply exceeded");
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

// The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        super._update(from, to, value);
    }

    // The following functions implement blacklisting.

    function addToBlacklist(address account) public onlyOwner {

        _blacklisted[account] = true;

    }

    function removeFromBlacklist(address account) public onlyOwner {

        _blacklisted[account] = false;

    }

    function isBlacklisted(address account) public view returns (bool) {

        return _blacklisted[account];

    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!_blacklisted[msg.sender], "Sender is blacklisted");
        require(!_blacklisted[recipient], "Recipient is blacklisted");
        require(amount <= maxTransactionAmount, "Transfer amount exceeds the maximum allowed");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!_blacklisted[sender], "Sender is blacklisted");
        require(!_blacklisted[recipient], "Recipient is blacklisted");
        require(amount <= maxTransactionAmount, "Transfer amount exceeds the maximum allowed");
        return super.transferFrom(sender, recipient, amount);
    }


}
