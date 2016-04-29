isHidden = (node) ->
  if node is document.documentElement
    return false
  if node.tabbableCacheIndex
    return nodeCache[node.tabbableCacheIndex]
  result = false
  style = window.getComputedStyle(node)
  if style.visibility is 'hidden' or style.display is 'none'
    result = true
  else if node.parentNode
    result = isHidden(node.parentNode)
  node.tabbableCacheIndex = nodeCacheIndex
  nodeCache[node.tabbableCacheIndex] = result
  nodeCacheIndex++
  result

module.exports = (el) ->
  basicTabbables = []
  orderedTabbables = []
  candidateNodelist = el.querySelectorAll('input, select, a, textarea, button, [tabindex]')
  candidates = Array::slice.call(candidateNodelist)
  candidate = undefined
  candidateIndex = undefined
  i = 0
  l = candidates.length
  while i < l
    candidate = candidates[i]
    candidateIndex = candidate.tabIndex
    if candidateIndex < 0 or (candidate.tagName is 'INPUT' and candidate.type is 'hidden') or (candidate.tagName is 'A' and not candidate.href and not candidate.tabIndex) or candidate.disabled or isHidden(candidate)
      i++
      continue
    if candidateIndex is 0
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

nodeCache = {}
nodeCacheIndex = 1
