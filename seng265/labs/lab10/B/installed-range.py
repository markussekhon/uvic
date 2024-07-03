#!/usr/bin/env python3
"""
Obtain and print the names of the packages without the cpu architecture (similar to A\installed4.py) that were installed within
the range of dates provided by the user (i.e., variables date_from and date_to). 

* Dates provided by the user should follow the format yyyy-mm-dd
* The output for each package belonging to the specified range should be:
yyyy-mm-dd: NAME_OF_PACKAGE
* An example of output from the program is described in range-2020-07-15-to-2020-07-16.txt

"""

import re
import sys

def main():
    if len(sys.argv) < 3:
        print("Usage: python script.py yyyy-mm-dd yyyy-mm-dd")
        sys.exit(1)
    date_from = sys.argv[1]
    date_to   = sys.argv[2]

    pattern = re.compile(r"(\d{4}-\d{2}-\d{2}).* installed ((.+):(.+)) .*")

    with open("dpkg.log") as file:
        for line in file:
            m = pattern.search(line.rstrip())
            if m:
                date = m.group(1)
                if date_from <= date <= date_to:
                    print("%s: %s" % (date, m.group(3)))

if __name__ == "__main__":
    main()
