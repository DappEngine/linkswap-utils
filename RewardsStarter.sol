pragma solidity 0.5.16;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.3.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.3.0/contracts/token/ERC20/SafeERC20.sol";

interface IStakingRewardsFactory {
    function notifyRewardAmount(address _stakingToken) external;
}

contract RewardsStarter {
    using SafeERC20 for IERC20;

    IERC20 public yfl;
    IStakingRewardsFactory public stakingRewardsFactory;

    constructor(address stakingRewardsFactoryAddress, address yflAddress) public {
        require(stakingRewardsFactoryAddress != address(0), "zero address");
        yfl = IERC20(yflAddress);
        stakingRewardsFactory = IStakingRewardsFactory(stakingRewardsFactoryAddress);
    }

    function startRewards(
        address _stakingToken,
        uint256 yflRewardAmount,
        address extraRewardTokenAddress,
        uint256 extraRewardAmount
    ) public {
        if (yflRewardAmount > 0) {
            yfl.transferFrom(msg.sender, address(stakingRewardsFactory), yflRewardAmount);
        }
        if (extraRewardAmount > 0) {
            IERC20(extraRewardTokenAddress).transferFrom(
                msg.sender,
                address(stakingRewardsFactory),
                extraRewardAmount
            );
        }
        stakingRewardsFactory.notifyRewardAmount(_stakingToken);
        if (yflRewardAmount > 0) {
            require(
                yfl.balanceOf(address(stakingRewardsFactory)) == 0,
                "too much yfl transferred to factory"
            );
        }
        if (extraRewardAmount > 0) {
            require(
                IERC20(extraRewardTokenAddress).balanceOf(address(stakingRewardsFactory)) == 0,
                "too much extra rewards token transferred to factory"
            );
        }
    }
}
