file_append_contact = "dmrid_svoi.dat"


data = []
with open(file_append_contact) as file:
    lines = [line.rstrip() for line in file]


for item in lines:
    dmrid = item[:7]
    callsing = item[8:-1]
    if len(callsing) > 7 or len(callsing) == 7:
        callsing = callsing[:7]
    # if len(callsing) == 6:
    #     callsing = callsing[:-1]
    if len(callsing) < 6:
        callsing = callsing
    new_line = dmrid + " " + callsing
    data.append(new_line)


with open(file_append_contact, "w") as file:
    file.writelines("%s\n" % line for line in data)
