path = require 'path-extra'
{__, __n} = require 'i18n'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem, TabbedArea, TabPane} = ReactBootstrap
{MissionPanel, NdockPanel, KdockPanel, TaskPanel, MiniShip, ResourcePanel, TeitokuPanel} = require './parts'
{MainHorizontal, MainVertical} = require './render'
# ThemeRender = require './path/to/theme'
ThemeRender = null

module.exports =
  name: 'MainView'
  priority: 0
  displayName: <span><FontAwesome key={0} name='home' />{__ ' Overview'}</span>
  description: '概览面板，提供基本的概览界面'
  reactClass: React.createClass
    getInitialState: ->
      layout: window.layout
      key: 1
    handleChangeLayout: (e) ->
      @setState
        layout: e.detail.layout
    handleSelect: (key) ->
      @setState {key}
      @forceUpdate()
    componentWillMount: ->
      if @state.layout == 'horizonal' or window.doubleTabbed
        @render = ThemeRender || MainHorizontal
      else
        @render = ThemeRender || MainVertical
    componentDidMount: ->
      window.addEventListener 'layout.change', @handleChangeLayout
    componentWillUnmount: ->
      window.removeEventListener 'layout.change', @handleChangeLayout
    shouldComponentUpdate: (nextProps, nextState) ->
      false
    render: ->
      <div>
      </div>
