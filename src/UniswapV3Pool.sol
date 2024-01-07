// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.14;
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3MintCallback.sol";
import "./lib/Tick.sol";
import "./lib/Position.sol";
import "./lib/TickMath.sol";

contract UniswapV3Pool {
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;
    //note that constants and immutable variables are not in the storage, they are in the bytecode
    // also note that constants are initialzed before the constructor is called and immutable variables are initialized during the constructor
    // or any time before the deployment of the contract
    // also the expression for the immutable variables must be constant expression
    // as the value of it is copied everywhere in the bytecode
    // but in case of constants, the value is not copied, instead the expression is copied everywhere in the bytecode
    // less gas is used in case of immutable variables as compared to constants
    //constants

    //immutable variables
    //each pool will have2 tokens whose addresses will  be immutable
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;
    int24 public immutable tickSpacing;
    uint128 public immutable maxLiquidityPerTick;

    // state variables

    //also we need do pack variables that are often read and written together into a single storage slot
    // note that this is called slot 0 because it is going to occupy the first slot in the storage
    // also note that that slot in the etherium storage is 32 bytes
    //out slot is less than 32 bytes
    // we are going to pack 2 variables into a single slot
    // uint160 is 20 bytes and int24 is 3 bytes so total 23 bytes that is less than 32 bytes
    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
        //unlocked is true if the pool is unlocked
        //this is used to prevent reentrancy attacks
        bool unlocked;
    }

    Slot0 public slot0;

    //current liquidity in the pool
    uint128 public liquidity;

    //Ticks info--> mapping from lower and upper tick to tick info//Tick info contains liquidity and initialized

    //Position info
    mapping(bytes32 => Position.Info) public positions;

    //events minting
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    //errors
    //zero liquidity error in case the owner of the liquidity gives 0 liquidity
    error ZeroLiquidity();

    //tick out of range or invalid
    error InvalidTick();

    //insuffiecient input amounts given
    error InsufficientInputAmount();

    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        int24 _tickspacing
    ) {
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        tickSpacing = _tickspacing;
        maxLiquidityPerTick = Tick.tickSpacingToMaximumLiquidty(_tickspacing);
    }

    function initialize(uint160 sqrtPriceX96) external {
        require(slot0.sqrtPriceX96 == 0, "ALREADY_INITIALIZED");
        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        slot0 = Slot0({sqrtPriceX96: sqrtPriceX96, tick: tick, unlocked: true});
    }
}
