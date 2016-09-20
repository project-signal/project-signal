import React, { Component } from 'react';
import { connect } from 'react-redux';
import Sidebar from './sidebar.jsx';
import MenuContent from './menu_content.jsx';
import _ from 'lodash';


function getResponses(signal, responses) {
  const data = [];

  _.forEach(signal.responses, function(key) {
    data.push(responses[key]);
  });
  return data;
};

function newSignal(signal, responses) {
  const newSignalObj = {};

  _.forEach(Object.keys(signal), function(key) {
    key == 'responses' ? newSignalObj[key] = getResponses(signal, responses) : newSignalObj[key] = signal[key]
  });

  return newSignalObj;
};

function getSignal(ownProps, state) {
  const { route, params } = ownProps;

  if (route.path === 'new') {
    return {
      type: params.type,
    }
  } else {
    const signals   = state.models.listenSignals.data;
    const key       = _.findKey(signals, { id: parseInt(params.id) });
    const signal    = signals[key];
    const responses = state.models.responses.data;

    return newSignal(signal, responses);
  }
}

class ContentPanel extends Component {
  constructor(props) {
    super(props);
    this.handleSideBar = this.handleSideBar.bind(this);
    this.state = {
      sidebarMenus: [
        { id: 1, contentId: 'edit', active: true },
        { id: 2, contentId: 'promote', active: false },
        { id: 3, contentId: 'preview', active: false },
        { id: 4, contentId: 'activity', active: false },
      ],
    };
  }

  handleSideBar(menu) {
    const newMenus = [ ...this.state.sidebarMenus ].map((menuItem) => {
      menuItem.active = menuItem.contentId === menu;
      return menuItem;
    });

    this.setState({ sidebarMenus: newMenus })
  }

  render() {
    const signal = this.props.signal

    return (
      <div className='content-panel'>
        <Sidebar
          menus={this.state.sidebarMenus}
          handleClick={this.handleSideBar}
          signalType={this.signalState}
        />
        <MenuContent
          menus={this.state.sidebarMenus}
          signal={signal}
        />
      </div>
    );
  }
}

export default connect((state, ownProps) => {
  return {
    signal: getSignal(ownProps, state)
  };
})(ContentPanel);

