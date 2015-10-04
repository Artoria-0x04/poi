{$, $$, layout} = window
{config, proxy} = window
{setBounds, getBounds} = remote.require './lib/utils'
WindowManager = remote.require './lib/window'

changeBounds = ->
  bound = getBounds()
  {x, y} = bound
  borderX = bound.width - window.innerWidth
  borderY = bound.height - window.innerHeight
  newHeight = window.innerHeight
  newWidth = window.innerWidth
  gameWidth = 800
  toolbarHeight = 30
  tabWidth = 400
  tabHeight = 768 - 480
  if layout == 'horizontal'
    newHeight = gameWidth / 800 * 480 + toolbarHeight
    newWidth = gameWidth + tabWidth
  else if layout == 'vertical'
    newHeight = gameWidth / 800 * 480 + tabHeight
    newWidth = gameWidth
  else if layout == 'L'
    newHeight = gameWidth / 800 * 480 + toolbarHeight + tabHeight
    newWidth = gameWidth + tabWidth
  setBounds
    x: x
    y: y
    width: parseInt(newWidth + borderX)
    height: parseInt(newHeight + borderY)

window._delay = false
window._layout = require "./layout.#{layout}"
window.addEventListener 'layout.change', (e) ->
  window._layout.unload()
  delete require.cache[require.resolve("./layout.#{layout}")]
  {layout} = e.detail
  changeBounds()
  window._layout = require "./layout.#{layout}"

document.addEventListener 'DOMContentLoaded', ->
  # Create new window for new window in webview
  $('kan-game webview').src = config.get 'poi.homepage', 'http://www.dmm.com/netgame/social/application/-/detail/=/app_id=854854/'
  $('kan-game webview').addEventListener 'new-window', (e) ->
    exWindow = WindowManager.createWindow
      realClose: true
      navigatable: true
      'node-integration': false
    exWindow.loadUrl e.url
    exWindow.show()
    e.preventDefault()
