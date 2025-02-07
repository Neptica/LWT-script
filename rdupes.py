import sys

temp = sys.argv[1]
output = sys.argv[2]

fixed = []
for line in open(temp, "r", encoding="UTF-8"):
    if not fixed:
        fixed.append(line)
        continue

    if fixed[-1] != line:
        fixed.append(line)

fixed_output = "\n".join(fixed)
open(output, "w", encoding="UTF-8").write(fixed_output)
