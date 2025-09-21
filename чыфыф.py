waysCnt = 0
def possibleWays(n):
    global waysCnt 
    if n == 3:
        waysCnt += 1
        return 1
    if n % 3 == 0 and n / 3 >= 3:
        possibleWays(n / 3)
    possibleWays(n - 1)
    return waysCnt

print(possibleWays(9))