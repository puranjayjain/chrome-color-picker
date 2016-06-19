createIsHidden = undefined

createIsHidden = ->
  isHidden = undefined
  nodeCache = undefined
  nodeCache = []

  isHidden = (node) ->
    cached = undefined
    result = undefined
    style = undefined
    if node == document.documentElement
      return false
    cached = nodeCache.find((item) ->
      item[0] == node
    )
    if cached
      return cached[1]
    result = false
    style = window.getComputedStyle(node)
    if style.visibility == 'hidden' or style.display == 'none'
      result = true
    else if node.parentNode
      result = isHidden(node.parentNode)
    nodeCache.push [
      node
      result
    ]
    result

module.exports = (el) ->
  basicTabbables = undefined
  candidate = undefined
  candidateIndex = undefined
  candidates = undefined
  i = undefined
  isHidden = undefined
  l = undefined
  orderedTabbables = undefined
  tabbableNodes = undefined
  basicTabbables = []
  orderedTabbables = []
  isHidden = createIsHidden()
  candidates = el.querySelectorAll('input, select, a[href], textarea, button, [tabindex]')
  candidate = undefined
  candidateIndex = undefined
  i = 0
  l = candidates.length
  while i < l
    candidate = candidates[i]
    candidateIndex = candidate.tabIndex
    if candidateIndex < 0 or candidate.tagName == 'INPUT' and candidate.type == 'hidden' or candidate.disabled or isHidden(candidate)
      i++
      continue
    if candidateIndex == 0
      basicTabbables.push candidate
    else
      orderedTabbables.push
        tabIndex: candidateIndex
        node: candidate
    i++
  tabbableNodes = orderedTabbables.sort((a, b) ->
    a.tabIndex - (b.tabIndex)
  ).map((a) ->
    a.node
  )
  Array::push.apply tabbableNodes, basicTabbables
  tabbableNodes
