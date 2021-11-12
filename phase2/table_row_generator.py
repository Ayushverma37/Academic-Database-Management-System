# This file creates table entries of all the tables

# random row generation for actor table
import numpy as np
import random
import string


def random_string(size, chars):
    return ''.join(random.choice(chars) for x in range(size))


data = np.random.permutation(300000)
chars_name = string.ascii_lowercase
size_name = 15
names_list = []
for y in range(300000):
    names_list.append(random_string(size_name, chars_name))

f = open('rows.txt', 'w')
for z in range(300000):
    f.write('INSERT INTO actor values (' + str(data[z]) + ',' + '\'' + names_list[z] + '\'' + ');\n')

f.close()

data_pc=np.random.permutation(80000)
chars_name_pc = string.ascii_lowercase
size_name_pc = 10
names_list_pc = []
for y in range(80000):
    names_list_pc.append(random_string(size_name_pc, chars_name_pc))

chars_address_pc = string.ascii_lowercase
address_list_pc = []
size_address_pc = 30
for y in range(80000):
    address_list_pc.append(random_string(size_address_pc, chars_address_pc))
f_pc = open('production.txt', 'w')
for z in range(80000):
    f_pc.write('INSERT INTO production_company values (' + str(data_pc[z]) + ',' + '\'' + names_list_pc[z] + '\''+  ',' + '\'' + address_list_pc[z] + '\'' + ');\n')

f_pc.close()


# random row generation for movie table

mid = np.random.permutation(1000000)
chars_name = string.ascii_lowercase     # list of chars to be used
size_name = 10                          # size of the random string
name_movie_list = []                    # list of random strings
imdb = []
for y in range(1000000):
    name_movie_list.append(random_string(size_name, chars_name))
    imdb.append(round(random.uniform(1.0, 5.0), 2))

pc_movie = np.random.permutation(np.append(np.random.randint(1, 501, 900000), np.random.randint(501, 80001, 100000)))
year = np.random.randint(1900, 2001, 1000000)

f = open('rows2.txt', 'w')               # opening a file to write insert commands
for z in range(1000000):
    f.write('INSERT INTO movie values('+str(mid[z])+', \''+name_movie_list[z]+'\', '+ str(year[z]) + ', ' + str(imdb[z]) + ', ' + str(pc_movie[z]) + ');\n')

f.close()


# random row generation for casting table
mid_casting=np.random.permutation(1000000)
aid_casting=np.random.permutation(np.append(np.random.randint(1, 10001, 3800000), np.random.randint(10001, 300001, 200000)))
f_casting = open('casting.txt', 'w')
for z in range(1000000):
    f_casting.write('INSERT INTO casting values('+str(mid_casting[z])+','+ str(aid_casting[z*1])+ ');\n')
    f_casting.write('INSERT INTO casting values('+str(mid_casting[z])+','+ str(aid_casting[z*2])+ ');\n')
    f_casting.write('INSERT INTO casting values('+str(mid_casting[z])+','+ str(aid_casting[z*3])+ ');\n')
    f_casting.write('INSERT INTO casting values('+str(mid_casting[z])+','+ str(aid_casting[z*4])+ ');\n')

f_casting.close()
