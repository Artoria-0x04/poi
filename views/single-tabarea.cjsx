path = require 'path-extra'
glob = require 'glob'
{_, $, $$, ROOT, notify, layout, React, ReactBootstrap} = window
{Grid, Col, Row, TabbedArea, TabPane, Navbar, Nav, NavItem, MenuItem, DropdownButton} = ReactBootstrap

rankName = ['', '元帥', '大将', '中将', '少将', '大佐', '中佐', '新米中佐', '少佐', '中堅少佐', '新米少佐']

# Get components
components = glob.sync(path.join(ROOT, 'views', 'components', '*'))

# Discover plugins and remove unused plugins
plugins = glob.sync(path.join(ROOT, 'plugins', '*'))
exPlugins = glob.sync(path.join(EXROOT, 'plugins', '*'))
plugins = plugins.concat(exPlugins)
plugins = plugins.filter (filePath) ->
  # Every plugin will be required
  try
    plugin = require filePath
    return config.get "plugin.#{plugin.name}.enable", true
  catch e
    return false

components = components.map (filePath) ->
  component = require filePath
  component.priority = 10000 unless component.priority?
  component
components = components.filter (component) ->
  component.show isnt false and component.name != 'SettingsView'
components = _.sortBy(components, 'priority')

PluginWrap = React.createClass
  shouldComponentUpdate: (nextProps, nextState)->
    false
  render: ->
    React.createElement @props.plugin.reactClass

plugins = plugins.map (filePath) ->
  plugin = require filePath
  plugin.priority = 10000 unless plugin.priority?
  plugin
plugins = plugins.filter (plugin) ->
  plugin.show isnt false
plugins = _.sortBy(plugins, 'priority')
tabbedPlugins = plugins.filter (plugin) ->
  !plugin.handleClick?
indivPlugins = plugins.filter (plugin) ->
  plugin.handleClick?
settings = require path.join(ROOT, 'views', 'components', 'settings')

lockedTab = false
ControlledTabArea = React.createClass
  getInitialState: ->
    level: 0
    nickname: null
    rank: 0
    key: [0, 0]
    xs: if layout == 'horizonal' then 4 else 4
  handleSelect: (key) ->
    @setState {key} if key isnt @state.key
  handleCtrlOrCmdTabKeyDown: ->
    @handleSelect 0
  handleCtrlOrCmdNumberKeyDown: (num) ->
    if num <= components.length + tabbedPlugins.length
      @handleSelect num - 1
  handleShiftTabKeyDown: ->
    @handleSelect if @state.key? then (@state.key - 1 + components.length + tabbedPlugins.length) % (components.length + tabbedPlugins.length) else components.length + tabbedPlugins.length - 1
  handleTabKeyDown: ->
    @handleSelect if @state.key? then (@state.key + 1) % (components.length + tabbedPlugins.length) else 1
  handleKeyDown: ->
    return if @listener?
    @listener = true
    window.addEventListener 'keydown', (e) =>
      if e.keyCode is 9
        e.preventDefault()
        return if lockedTab and e.repeat
        lockedTab = true
        setTimeout ->
          lockedTab = false
        , 200
        if e.ctrlKey or e.metaKey
          @handleCtrlOrCmdTabKeyDown()
        else if e.shiftKey
          @handleShiftTabKeyDown()
        else
          @handleTabKeyDown()
      else if e.ctrlKey or e.metaKey
        if e.keyCode >= 49 and e.keyCode <= 57
          @handleCtrlOrCmdNumberKeyDown(e.keyCode - 48)
        else if e.keyCode is 48
          @handleCtrlOrCmdNumberKeyDown 10
  componentDidMount: ->
    window.addEventListener 'game.start', @handleKeyDown
  render: ->
    ### FIXME
    # Animation disabled
    # Relate to https://github.com/react-bootstrap/react-bootstrap/issues/287
    ###
    <TabbedArea activeKey={@state.key} onSelect={@handleSelect} animation={false}>
    {
      [
        components.map (component, index) =>
          <TabPane key={index} eventKey={index} tab={component.displayName} id={component.name} className='poi-app-tabpane'>
          {
            React.createElement component.reactClass,
              selectedKey: @state.key
              index: index
          }
          </TabPane>
        <DropdownButton key={components.length}
                        eventKey={-1}
                        tab=
                        {
                          if @state.key >= components.length and @state.key < 1000
                            <span>插件 - {plugins[@state.key - components.length].displayName}</span>
                          else
                            '插件'
                        }
                        navItem={true}>
        {
          counter = 0
          plugins.map (plugin, index) =>
            if plugin.handleClick
              <div key={components.length + 1 + index} eventKey={0} tab={plugin.displayName} id={plugin.name} onClick={plugin.handleClick} />
            else
              key = components.length - 1 + (counter += 1)
              <TabPane key={components.length + 1 + index} eventKey={key} tab={plugin.displayName} id={plugin.name} className='poi-app-tabpane'>
                <PluginWrap plugin={plugin} selectedKey={@state.key} index={key} />
              </TabPane>
        }
        </DropdownButton>
        <TabPane key={1000} eventKey={1000} tab={settings.displayName} id={settings.name} className='poi-app-tabpane'>
        {
          React.createElement settings.reactClass,
            selectedKey: @state.key
            index: 1000
        }
        </TabPane>
      ]
    }
    </TabbedArea>

module.exports = ControlledTabArea
