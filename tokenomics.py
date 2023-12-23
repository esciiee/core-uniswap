import math

# prices: price of token0 in terms of token1
def price_to_tick(price):
    return math.floor(math.log(price, 1.0001))

def price_to_sqrtp_q64_96(price):
    return int(math.sqrt(price)*q64_96)

# liquidity to the left of the current price
def liquidity_token0(del_token0, price_current, price_high):
    return del_token0 * math.sqrt(price_current)*math.sqrt(price_high)/(math.sqrt(price_high)-math.sqrt(price_low))

# liquidity to the right of the current price
def liquidity_token1(del_token1, price_low, price_current):
    return del_token1/(math.sqrt(price_current)-math.sqrt(price_low))



# suppose token0 is eth and token1 is usdc
# suppose the price of eth is 2000 usdc
# sppose the pool has 1 eth and 2000 usdc
# we will represent num in form of Q64.96
q64_96 = 2**96
eth = 10**18
amount_token0 = 1
amount_token1 = 2000
price_high = 2300
price_current = 2000
price_low = 1700
liq0 = q64_96*(liquidity_token0(amount_token0, price_current, price_high))
liq1 = q64_96*(liquidity_token1(amount_token1, price_low, price_current))

liquidity = min(liq0, liq1)

# calculating amounts again to not loose precesion
def calc_amount0(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * q96 * (pb - pa) / pa / pb)


def calc_amount1(liq, pa, pb):
    if pa > pb:
        pa, pb = pb, pa
    return int(liq * (pb - pa) / q96)

amount0 = calc_amount0(liq0, price_to_sqrtp_q64_96(price_high), price_to_sqrtp_q64_96(price_current))
amount1 = calc_amount1(liq1, price_to_sqrtp_q64_96(price_low), price_to_sqrtp_q64_96(price_current))




