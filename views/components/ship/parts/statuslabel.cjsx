{$, $$, _, React, ReactBootstrap} = window
{Label} = ReactBootstrap

###
# usage:
# get a ship's all status using props, sorted by status priority
# status array: [retreat, repairing, special1, special2, special3]
# value: boolean
###
StatusLabel = React.createClass
  componentDidMount: ->
    @forceUpdate()
  render: ->
    if @props.label[0]? and @props.label[0]
      <Label bsStyle="danger">退<br/>避</Label>
    else if @props.label[1]? and @props.label[1]
      <Label bsStyle="info">修<br/>理</Label>
    else if @props.label[2]? and @props.label[2]
      <Label bsStyle="info"><FontAwesome key={0} name='lock' /><br/>I</Label>
    else if @props.label[3]? and @props.label[3]
      <Label bsStyle="primary"><FontAwesome key={0} name='lock' /><br/>II</Label>
    else if @props.label[4]? and @props.label[4]
      <Label bsStyle="success"><FontAwesome key={0} name='lock' /><br/>III</Label>
    else if @props.label[4]? and @props.label[5]
      <Label bsStyle="warning"><FontAwesome key={0} name='lock' /><br/>IV</Label>
    else
      <Label bsStyle="default" style={border:"1px solid "}></Label>

module.exports = StatusLabel
