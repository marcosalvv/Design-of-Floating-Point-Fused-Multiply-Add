import numpy as np
# Convert the float to the his binary representation
def float2bin(float):   
    bin = '{:032b}'.format(np.float32(float).view(np.uint32).item())
    return bin
# Shift an arry of n position and fill with NaN
def shift(xs, n):
    e = np.empty_like(xs)
    if n >= 0:
        e[:n] = np.nan
        e[n:] = xs[:-n]
    else:
        e[n:] = np.nan
        e[:n] = xs[-n:]
    return e

seed = 14517549454223434347525082322699234253443342275079629348737
n_entry = 1000000
mant_low = 1.175494350822287507968737
mant_high = 3.402823466385288598117042
exp_low = -38
exp_high = 39
# exp_low = -1
# exp_high = 2

rng = np.random.default_rng(seed)
# Generate a random sign
sign = rng.choice((-1, 1), size=(n_entry,3))
# Generate a random mantissa
mant = rng.uniform(mant_low, mant_high, size=(n_entry,3))
# Generate a random exponent
exp = rng.integers(exp_low, exp_high, size=(n_entry,3))
# Generate a random float32 of x,y and w inputs
float32_in = np.float32(sign*mant*(10.**exp))
# Convert to float128
float128_in = np.longdouble(float32_in)
# Determine the result x*y+w, utilizing the float128 for better precision and to prevent overflow
float128_out = np.prod(float128_in[:,0:2],axis=1) + float128_in[:,2]
float32_out = np.float32(float128_out)
# Add the result as the last column of float_in
float32 = np.column_stack((float32_in,float32_out))
# Stack on the bottom of the array two rows of NaN
float32 = np.concatenate((float32,np.full((2, 4), np.nan)), axis=0)
# Shift the column of the result of 2 position below and fill with NaN
float32[:,3] = shift(float32[:,3],2)
# Convert the float to the his binary representation
v_float2bin = np.vectorize(float2bin)
float32 = v_float2bin(float32)
# Print the float array to a file
np.savetxt('template.txt', float32, delimiter=' ', fmt='%s')