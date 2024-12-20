// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract DolaToken is ERC20 {
    AggregatorV3Interface public priceFeed;
    ERC20 public bdola;
    address public admin;
    uint256 public collateralizationRatio = 150;

    event MintedDola(address indexed user, uint256 bdolaAmount, uint256 dolaAmount);
    event RedeemedDola(address indexed user, uint256 dolaAmount, uint256 bdolaAmount);
    event CollateralizationRatioUpdated(uint256 oldRatio, uint256 newRatio);
    event AdminTransferred(address oldAdmin, address newAdmin);

    constructor(address _priceFeed, address _bdola) ERC20("Dola Token", "DOLA") {
        admin = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
        bdola = ERC20(_bdola);
    }

    /**
     * @dev Mint DOLA by depositing BDOLA as collateral.
     * @param _bdolaAmount Amount of BDOLA to deposit.
     */
    function mintDola(uint256 _bdolaAmount) external {
        require(_bdolaAmount > 0, "Invalid collateral amount");
        uint256 dolaAmount = (_bdolaAmount * getROIPrice() * 100) / collateralizationRatio;
        require(bdola.transferFrom(msg.sender, address(this), _bdolaAmount), "Collateral transfer failed");
        _mint(msg.sender, dolaAmount);

        emit MintedDola(msg.sender, _bdolaAmount, dolaAmount);
    }

    /**
     * @dev Redeem DOLA for BDOLA collateral.
     * @param _dolaAmount Amount of DOLA to redeem.
     */
    function redeemDola(uint256 _dolaAmount) external {
        require(_dolaAmount > 0, "Invalid DOLA amount");
        uint256 bdolaAmount = (_dolaAmount * collateralizationRatio) / (100 * getROIPrice());
        _burn(msg.sender, _dolaAmount);
        require(bdola.transfer(msg.sender, bdolaAmount), "Collateral transfer failed");

        emit RedeemedDola(msg.sender, _dolaAmount, bdolaAmount);
    }

    /**
     * @dev Fetch the latest ROI price from the Chainlink oracle.
     * @return Price of 1 ROI token in USD, scaled to 18 decimals.
     */
    function getROIPrice() public view returns (uint256) {
        (, int price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed data");
        return uint256(price) * (10 ** (18 - priceFeed.decimals()));
    }

    /**
     * @dev Update the collateralization ratio. Admin only.
     * @param _newRatio New collateralization ratio.
     */
    function updateCollateralizationRatio(uint256 _newRatio) external {
        require(msg.sender == admin, "Only admin can update");
        require(_newRatio >= 100, "Ratio must be at least 100%");
        emit CollateralizationRatioUpdated(collateralizationRatio, _newRatio);
        collateralizationRatio = _newRatio;
    }

    /**
     * @dev Transfer admin role to a new address.
     * @param _newAdmin New admin address.
     */
    function transferAdmin(address _newAdmin) external {
        require(msg.sender == admin, "Only admin can transfer");
        require(_newAdmin != address(0), "Invalid new admin");
        emit AdminTransferred(admin, _newAdmin);
        admin = _newAdmin;
    }
}
