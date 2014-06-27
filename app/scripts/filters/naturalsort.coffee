'use strict'

module = angular.module 'cybFileBrowser'


# * Natural Sort algorithm for Javascript - Version 0.7 - Released under MIT license
# * Author: Jim Palmer (based on chunking idea from Dave Koelle)
# * URL: http://www.overset.com/2008/09/01/javascript-natural-sort-algorithm/
#
naturalSort = (a, b) ->
  re = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?$|^0x[0-9a-f]+$|[0-9]+)/g
  sre = /(^[ ]*|[ ]*$)/g
  dre = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/
  hre = /^0x[0-9a-f]+$/i
  ore = /^0/
  i = (s) ->
    naturalSort.insensitive and ("" + s).toLowerCase() or "" + s


  # convert all to strings strip whitespace
  x = i(a).replace(sre, "") or ""
  y = i(b).replace(sre, "") or ""

  # chunk/tokenize
  xN = x.replace(re, "\u0000$1\u0000").replace(/\0$/, "").replace(/^\0/, "").split("\u0000")
  yN = y.replace(re, "\u0000$1\u0000").replace(/\0$/, "").replace(/^\0/, "").split("\u0000")

  # numeric, hex or date detection
  xD = parseInt(x.match(hre)) or (xN.length isnt 1 and x.match(dre) and Date.parse(x))
  yD = parseInt(y.match(hre)) or xD and y.match(dre) and Date.parse(y) or null
  oFxNcL = undefined
  oFyNcL = undefined

  # first try and sort Hex codes or Dates
  if yD
    if xD < yD
      return -1
    else return 1  if xD > yD

  # natural sorting through split numeric strings and default strings
  cLoc = 0
  numS = Math.max(xN.length, yN.length)

  while cLoc < numS

    # find floats not starting with '0', string or 0 if not defined (Clint Priest)
    oFxNcL = not (xN[cLoc] or "").match(ore) and parseFloat(xN[cLoc]) or xN[cLoc] or 0
    oFyNcL = not (yN[cLoc] or "").match(ore) and parseFloat(yN[cLoc]) or yN[cLoc] or 0

    # handle numeric vs string comparison - number < string - (Kyle Adams)
    if isNaN(oFxNcL) isnt isNaN(oFyNcL)
      return (if (isNaN(oFxNcL)) then 1 else -1)

    # rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
    else if typeof oFxNcL isnt typeof oFyNcL
      oFxNcL += ""
      oFyNcL += ""
    return -1  if oFxNcL < oFyNcL
    return 1  if oFxNcL > oFyNcL
    cLoc++
  0


# Angular.js wrapper around the naturalSort function, with added support for sortKey
module.filter 'naturalSort', ->
  (input, caseInsensitive, sortKey) ->
    output = JSON.parse JSON.stringify input
    if caseInsensitive
      naturalSort.insensitive = true
    else
      naturalSort.insensitive = false

    if sortKey
      output.sort (a, b) ->
        naturalSort a[sortKey], b[sortKey]
    else
      output.sort naturalSort
