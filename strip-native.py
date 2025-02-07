import sys

temp = sys.argv[1]
output = sys.argv[2]

fixed = []
working = ""
for line in open(temp, "r", encoding="UTF-8"):
    if line == "\n":
        continue

    line = line.strip()
    if line[-1] == ".":
        working += line
        fixed.append(working)
        working = ""
    elif working != "":
        working += " " + line
    else:
        working += line


fixed_output = "\n\n".join(fixed)
open(output, "w", encoding="UTF-8").write(fixed_output)
