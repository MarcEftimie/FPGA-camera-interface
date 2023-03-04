import random
columns = 640
rows = 480
f = open("mem/vram.mem", "w")
f.truncate(0)
for i in range(0, int((rows*columns)/4)):
    f.write(format(random.randint(0, (2**12)-1), '012b') + "\n")
f.close()

f = open("mem/zeros.mem", "w")
f.truncate(0)
for i in range(0, int((rows*columns)/4)):
    f.write("000000000000\n")
f.close()
