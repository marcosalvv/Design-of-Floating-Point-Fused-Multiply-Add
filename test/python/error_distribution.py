import numpy as np
import struct
import seaborn as sns
import matplotlib.pyplot as plt

# Shift an arry of n position and fill with NaN
def shift(xs, n):
    e = np.empty_like(xs)
    if n >= 0:
        e[:n] = "01111111110000000000000000000000"
        e[n:] = xs[:-n]
    else:
        e[n:] = "01111111110000000000000000000000"
        e[:n] = xs[-n:]
    return e
# Convert from binary representation of float32 to float32
def bin_to_float(binary):
    return struct.unpack('!f',struct.pack('!I', int(binary, 2)))[0]
# Convert the float to the his binary representation
def float_to_bin(float):   
    bin = '{:032b}'.format(np.float32(float).view(np.uint32).item())
    return bin
# Convert from binary representation of float32 to an array of int of 0s and 1s
def bin_to_int_array(bin):   
    int_array = np.frombuffer(bin, dtype=int) - 48 #BOH, funziona ma non capisco
    return int_array


# Inferior limit of the histogram
x_inf = -1e-7
# Superior limit of the histogram
x_sup = 1e-7
# Number of bins
n_bins = 49
file = 'results - round_pos_inf.txt'

# Load the inputs and the output array from a file
float_bin = np.loadtxt(file, dtype = 'str', delimiter=' ')
# Shift the column of the result of 2 position below and fill with NaN
float_bin[:,3] = shift(float_bin[:,3],-2)
# Delete the last two rows
float_bin = np.delete(float_bin, (-2,-1), axis=0)
# Convert from binary representation of float32 to float128
v_bin2float = np.vectorize(bin_to_float)
float128 = np.longdouble(v_bin2float(float_bin))
# Expected output in float128
out_expected = np.prod(float128[:,0:2],axis=1) + float128[:,2]
# Eliminate infinite value and the subnormal value
mask_inf = np.isfinite(float128[:,3])
mask_sub = np.abs(out_expected) >= 1.175494350822287507968737E-38
mask = np.logical_and(mask_inf,mask_sub)
float_bin = float_bin[mask,:]
float128 = float128[mask,:]
out_expected = out_expected[mask]

# Error beetween the FMA output and the expected output
error = out_expected - float128[:,3]
# Error relative to the expected output magnitude
error_rel = error / np.abs(out_expected)


# Convert expected output in binary representeation
v_float_to_bin = np.vectorize(float_to_bin)
out_expected_bin = v_float_to_bin(out_expected)
# Convert expected output in array of int
v_bin_to_int_array = np.vectorize(bin_to_int_array, signature='()->(n)')
out_expected_int_array = v_bin_to_int_array(out_expected_bin)
# Convert output in array of int
out_int_array = v_bin_to_int_array(float_bin[:,3])
# Convert expected output in array of bool
out_expected_bool = out_expected_int_array.astype(bool)
# Convert output in array of bool
out_bool = out_int_array.astype(bool)
# Detect the number of error beetween relative to the binary position
error_bin = np.logical_xor(out_expected_bool,out_bool)
error_bin = error_bin.astype(float)
error_bin = np.sum(error_bin, axis=0)

print(error_bin)


# Plot relative error
fig0, ax0 = plt.subplots()
fig0.set_size_inches(7.5, 6)
ax0.hist(error_rel, bins=n_bins, range= (x_inf, x_sup), log= True, color='lightgreen',
        ec='black', density=False)
ax0.set(xlim=(x_inf, x_sup))
ax0.set_xlabel('Relative error', fontsize=15)  # Add an x-label to the Axes.
ax0.set_ylabel('Counts', fontsize=15)  # Add a y-label to the Axes.
ax0.set_title("Relative error distribution", fontsize=20)  # Add a title to the Axes.

fig1, ax1 = plt.subplots()
fig1.set_size_inches(7.5, 6)
ax1.bar(0.5 + np.arange(32), error_bin, color='lightgreen',
        ec='black')
ax1.set_xlabel('Bit position', fontsize=15)  # Add an x-label to the Axes.
ax1.set_ylabel('Counts', fontsize=15)  # Add a y-label to the Axes.
ax1.set_title("Bit position error", fontsize=20)  # Add a title to the Axes.
# ax1.set_ylim([0,1])
plt.xticks(ticks=0.5 + np.arange(32), labels=np.flip(np.arange(32)), fontsize=5)
plt.show()
