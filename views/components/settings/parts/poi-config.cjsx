path = require 'path-extra'
fs = require 'fs-extra'
glob = require 'glob'
rimraf = require 'rimraf'
{$, $$, _, React, ReactBootstrap, FontAwesome, ROOT} = window
{Grid, Col, Button, ButtonGroup, Input, Alert} = ReactBootstrap
{config, toggleModal} = window
{APPDATA_PATH} = window
{showItemInFolder, openItem} = require 'shell'
Divider = require './divider'
NavigatorBar = require './navigator-bar'
themes = glob.sync(path.join(ROOT, 'assets', 'themes', '*')).map (filePath) ->
  path.basename filePath
PoiConfig = React.createClass
  getInitialState: ->
    gameWidth =
      if (config.get 'poi.webview.width', -1) == -1
        if config.get('poi.layout', 'horizonal') == 'horizonal'
          window.innerWidth * (if window.doubleTabbed then 4.0 / 7.0 else 5.0 / 7.0)
        else
          window.innerWidth
      else
        config.get 'poi.webview.width', -1
    layout: config.get 'poi.layout', 'horizonal'
    theme: config.get 'poi.theme', '__default__'
    gameWidth: gameWidth
    useFixedResolution: config.get('poi.webview.width', -1) != -1
    enableConfirmQuit: config.get 'poi.confirm.quit', false
    enableDoubleTabbed: config.get 'poi.tabarea.double', false
    enableNotifySound: config.get 'poi.notify.sound', true
  handleSetConfirmQuit: ->
    enabled = @state.enableConfirmQuit
    config.set 'poi.confirm.quit', !enabled
    @setState
      enableConfirmQuit: !enabled
  handleSetNotifySound: ->
    enabled = @state.enableNotifySound
    config.set 'poi.notify.sound', !enabled
    @setState
      enableNotifySound: !enabled
  handleSetDoubleTabbed: ->
    enabled = @state.enableDoubleTabbed
    config.set 'poi.tabarea.double', !enabled
    @setState
      enableDoubleTabbed: !enabled
    toggleModal '布局设置', '设置成功，请重新打开软件使得布局生效。'
  handleSetLayout: (layout) ->
    return if @state.layout == layout
    config.set 'poi.layout', layout
    event = new CustomEvent 'layout.change',
      bubbles: true
      cancelable: true
      detail:
        layout: layout
    window.dispatchEvent event
    @setState {layout}
  handleSetTheme: (theme) ->
    theme = @refs.theme.getValue()
    return if @state.theme == theme
    config.set 'poi.theme', theme
    event = new CustomEvent 'theme.change',
      bubbles: true
      cancelable: true
      detail:
        theme: theme
    window.dispatchEvent event
    @setState {theme}
  handleSetWebviewWidth: (e) ->
    @setState
      gameWidth: @refs.webviewWidth.getValue()
    width = parseInt @refs.webviewWidth.getValue()
    return if isNaN(width) || width < 0 || !@state.useFixedResolution || (config.get('poi.layout', 'horizonal') == 'horizonal' && width > window.innerWidth - 150)
    window.webviewWidth = width
    window.dispatchEvent new Event('webview.width.change')
    config.set 'poi.webview.width', width
  handleResize: ->
    {gameWidth} = @state
    width = parseInt gameWidth
    return if isNaN(width) || width < 0 || (config.get('poi.layout', 'horizonal') == 'horizonal' && width > window.innerWidth - 150)
    if !@state.useFixedResolution
      if config.get('poi.layout', 'horizonal') == 'horizonal'
        @setState
          gameWidth: window.innerWidth * (if window.doubleTabbed then 4.0 / 7.0 else 5.0 / 7.0)
      else
        @setState
          gameWidth: window.innerWidth
  handleSetFixedResolution: (e) ->
    current = @state.useFixedResolution
    if current
      config.set 'poi.webview.width', -1
      @setState
        useFixedResolution: false
      @handleResize()
      window.webviewWidth = -1
      window.dispatchEvent new Event('webview.width.change')
    else
      @state.useFixedResolution = true
      @setState
        useFixedResolution: true
      @handleSetWebviewWidth()
  handleClearCookie: (e) ->
    rimraf path.join(APPDATA_PATH, 'Cookies'), (err) ->
      if err?
        toggleModal '删除 Cookies', "删除失败，你可以手动删除 #{path.join(APPDATA_PATH, 'Cookies')}"
        try
            fs.ensureFileSync APPDATA_PATH
            showItemInFolder path.join(APPDATA_PATH, 'Cookies')
        catch e
            toggleModal '打开缓存目录','打开失败，可能没有访问权限'
      else
        toggleModal '删除 Cookies', '删除成功，请立刻重启软件。'
  handleClearCache: (e) ->
    error = null
    rimraf path.join(APPDATA_PATH, 'Cache'), (err) ->
      error = error || err
      rimraf path.join(APPDATA_PATH, 'Pepper Data'), (err) ->
        error = error || err
        if error
          toggleModal '删除浏览器缓存', "删除失败，你可以手动删除 #{path.join(APPDATA_PATH, 'Cache')}"
          try
            fs.ensureFileSync APPDATA_PATH
            showItemInFolder path.join(APPDATA_PATH, 'Cache')
          catch e
            toggleModal '打开缓存目录','打开失败，可能没有访问权限'
        else
          toggleModal '删除浏览器缓存', '删除成功，请立刻重启软件。'
  handleOpenCustomCss: (e) ->
    try
      d = path.join(EXROOT, 'hack', 'custom.css')
      fs.ensureFileSync d
      openItem d
    catch e
      toggleModal '编辑自定义 CSS', '打开失败，可能没有创建文件的权限'
  componentDidMount: ->
    window.addEventListener 'resize', @handleResize
  componentWillUnmount: ->
    window.removeEventListener 'resize', @handleResize
  render: ->
    <form id="poi-config">
      <div className="form-group" id='navigator-bar'>
        <Divider text="浏览器" />
        <NavigatorBar />
        <Grid>
          <Col xs={12}>
            <Input type="checkbox" label="关闭前弹出确认窗口" checked={@state.enableConfirmQuit} onChange={@handleSetConfirmQuit} />
          </Col>
          <Col xs={12}>
            <Input type="checkbox" label="开启通知提示音" checked={@state.enableNotifySound} onChange={@handleSetNotifySound} />
          </Col>
        </Grid>
      </div>
      <div className="form-group">
        <Divider text="布局" />
        <Grid>
          <Col xs={6}>
            <Button bsStyle={if @state.layout == 'horizonal' then 'success' else 'info'} onClick={@handleSetLayout.bind @, 'horizonal'} style={width: '100%'}>
              {if @state.layout == 'horizonal' then '√ ' else ''}使用横版布局
            </Button>
          </Col>
          <Col xs={6}>
            <Button bsStyle={if @state.layout == 'vertical' then 'success' else 'info'} onClick={@handleSetLayout.bind @, 'vertical'} style={width: '100%'}>
              {if @state.layout == 'vertical' then '√ ' else ''}使用纵版布局
            </Button>
          </Col>
          <Col xs={12}>
            <Input type="checkbox" label="切分组件与插件面板" checked={@state.enableDoubleTabbed} onChange={@handleSetDoubleTabbed} />
          </Col>
        </Grid>
      </div>
      <div className="form-group">
        <Divider text="Cookies 和缓存" />
        <Grid>
          <Col xs={6}>
            <Button bsStyle="danger" onClick={@handleClearCookie} style={width: '100%'}>
              删除 Cookies
            </Button>
          </Col>
          <Col xs={6}>
            <Button bsStyle="danger" onClick={@handleClearCache} style={width: '100%'}>
              删除浏览器缓存
            </Button>
          </Col>
          <Col xs={12}>
            <Alert bsStyle='info' style={marginTop: '20px'}>
              如果经常猫，删除以上两项。
            </Alert>
          </Col>
        </Grid>
      </div>
      <div className="form-group">
        <Divider text="主题" />
        <Grid>
          <Col xs={6}>
            <Input type="select" ref="theme" value={@state.theme} onChange={@handleSetTheme}>
              {
                themes.map (theme, index) ->
                  <option key={index} value={theme}>{theme[0].toUpperCase() + theme.slice(1)}</option>
              }
              <option key={-1} value="__default__">Default</option>
            </Input>
          </Col>
          <Col xs={6}>
            <Button bsStyle='primary' onClick={@handleOpenCustomCss} block>编辑自定义 CSS</Button>
          </Col>
        </Grid>
      </div>
      <div className="form-group">
        <Divider text="游戏分辨率" />
        <div style={display: 'flex', marginLeft: 15, marginRight: 15}>
          <Input type='checkbox' ref="useFixedResolution" label='使用固定分辨率' checked={@state.useFixedResolution} onChange={@handleSetFixedResolution} />
        </div>
        <div id="poi-resolution-config" style={display: 'flex', marginLeft: 15, marginRight: 15, alignItems: 'center'}>
          <div style={flex: 1}>
            <Input type="number" ref="webviewWidth" value={@state.gameWidth} onChange={@handleSetWebviewWidth} readOnly={!@state.useFixedResolution} />
          </div>
          <div style={flex: 'none', width: 15, paddingLeft: 5}>
            x
          </div>
          <div style={flex: 1}>
            <Input type="number" value={@state.gameWidth * 480 / 800} readOnly />
          </div>
          <div style={flex: 'none', width: 15, paddingLeft: 5}>
            px
          </div>
        </div>
      </div>
    </form>

module.exports = PoiConfig
