# This file creates table entries of all the tables

# random row generation for actor table
import numpy as np
import random
import string


def random_string(size, chars):
    return ''.join(random.choice(chars) for x in range(size))


data = np.random.permutation(80000)
chars_name = string.ascii_lowercase
size_name = 10
names_list = []
for y in range(80000):
    names_list.append(random_string(size_name, chars_name))

f = open('rows.txt', 'w')
for z in range(80000):
    f.write('INSERT INTO actor values (' + str(data[z]) + ',' + '\'' + names_list[z] + '\'' + ');\n')

f.close()
