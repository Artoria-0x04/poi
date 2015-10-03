{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem, TabbedArea, TabPane} = ReactBootstrap
{MissionPanel, NdockPanel, KdockPanel, TaskPanel, MiniShip, ResourcePanel, TeitokuPanel} = require '../parts'

render = ->
  <div className="panel-row">
    <div className="panel-col" style={width: "60%"}>
      <div className="panel-col teitoku-panel">
        <TeitokuPanel />
      </div>
      <div className="panel-row">
        <div className="panel-col half">
          <div className="panel-col resource-panel" ref="resourcePanel">
            <ResourcePanel />
          </div>
          <div className="panel-col task-panel" ref="taskPanel">
            <TaskPanel />
          </div>
        </div>
        <div className="panel-col half">
          <Panel className="combinedPanels panel-col">
            <TabbedArea activeKey={@state.key} onSelect={@handleSelect} animation={false}>
             <TabPane eventKey={1} tab={__ 'Docking'}>
               <div className="panel-col ndock-panel flex">
                 <NdockPanel />
               </div>
             </TabPane>
             <TabPane eventKey={2} tab={__ 'Construction'}>
               <div className="panel-col kdock-panel flex">
                 <KdockPanel />
               </div>
             </TabPane>
            </TabbedArea>
          </Panel>
          <div className="panel-col mission-panel" ref="missionPanel">
            <MissionPanel />
          </div>
        </div>
      </div>
    </div>
    <div className="miniship panel-col" id={MiniShip.name} ref="miniship" style={width:"40%"}>
      {React.createElement MiniShip.reactClass}
    </div>
  </div>
