// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.14;
import "./TickMath.sol";

library Tick {
    function tickSpacingToMaximumLiquidty(
        int24 tickSpacing
    ) internal pure returns (uint128) {
        //convert min and max tick to multiple of tick spacing
        int24 minTick = (TickMath.MIN_TICK / tickSpacing) * tickSpacing;
        int24 maxTick = (TickMath.MAX_TICK / tickSpacing) * tickSpacing;

        //calculating number of ticks b/w max and min
        uint24 numOfTicks = uint24((maxTick - minTick) / tickSpacing) + 1;
        /// @dev: note that the max value of liq is 2^128 - 1;
        return type(uint128).max / numOfTicks;
    }
}
