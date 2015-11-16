document.addEventListener('DOMContentLoaded', ->

  checkPageButton = document.getElementById('checkPage')
  checkPageButton.addEventListener('click', ->

    chrome.tabs.getSelected null, (tab) ->
      d = document
      f = d.createElement 'form'
      f.action = 'http://gtmetrix.com/analyze.html?bm'
      i = d.createElement 'input'
      i.type = 'hidden'
      i.name = 'url'
      i.value = tab.url
      f.appendChild i
      d.body.appendChild f
      f.submit()
  , false)
, false)
