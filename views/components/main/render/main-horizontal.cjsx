{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem, TabbedArea, TabPane} = ReactBootstrap
{MissionPanel, NdockPanel, KdockPanel, TaskPanel, MiniShip, ResourcePanel, TeitokuPanel} = require '../parts'

render = ->
  <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), 'assets', 'main.css')} />
  <div className="panel-col">
    <div className="panel-col teitoku-panel">
      <TeitokuPanel />
    </div>
    <div className="panel-row">
      <div className="panel-col half">
        <div className="panel-col resource-panel" ref="resourcePanel">
          <ResourcePanel />
        </div>
        <div className="miniship" id={MiniShip.name} ref="miniship">
          {React.createElement MiniShip.reactClass}
        </div>
      </div>
      <div className="panel-col half">
        <Panel className="combinedPanels panel-col">
          <TabbedArea activeKey={@state.key} onSelect={@handleSelect} animation={false}>
           <TabPane eventKey={1} tab={__ 'Docking'}>
             <div className="ndock-panel flex">
               <NdockPanel />
             </div>
           </TabPane>
           <TabPane eventKey={2} tab={__ 'Construction'}>
             <div className="kdock-panel flex">
               <KdockPanel />
             </div>
           </TabPane>
          </TabbedArea>
        </Panel>
        <div className="mission-panel" ref="missionPanel">
          <MissionPanel />
        </div>
        <div className="task-panel" ref="taskPanel">
          <TaskPanel />
        </div>
      </div>
    </div>
  </div>

module.exports = render
