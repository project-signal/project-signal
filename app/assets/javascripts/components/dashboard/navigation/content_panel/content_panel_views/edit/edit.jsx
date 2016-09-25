import React, { Component } from 'react';
import _ from 'lodash';
import Calendar from './calendar.jsx';
import InputBox from '../../../../../forms/inputBox.jsx';
import SaveBtn from './save_btn.jsx';
import AddBtn from './add_btn.jsx';
import SignalIcon from '../../../../../links/signal_icon.jsx';

export default class Edit extends Component {
  constructor(props) {
    super(props);
    this.setResponse = this.setResponse.bind(this);

    this.editSignalName = this.editSignalName.bind(this);
  }

  setResponse(key, value) {
    var obj = {};
    obj[key] = value;
    this.setState(obj);
  }

  editSignalName() {
    const { signal } = this.props;

    if (signal.id) {
      return (
        <h4 className='subheading'>@Brand #{signal.name}</h4>
      );
    } else {
      return (
        <h4 className='subheading'>@Brand #
         <InputBox
            name="name"
            placeholder={`Ex. ${signal.signal_type}`}
            componentClass="input"
            className='signal-name-edit uctext'
          />
        </h4>
      );
    }
  }

  render() {
    const { signal } = this.props;
    const responses = _.get(signal, 'responses', [{},{}]);

    return (
      <div className='col-md-9 content-box'>
        <div className='content-header'>
          <SignalIcon type={signal.signal_type} className='content-icon' />
          <SignalIcon type='explanation' className='content-explanation' />
          <p className='signal-type-label'>TYPE</p>
          <h3 className='signal-type-header uctext'>{signal.signal_type} Signal</h3>
          <p className='signal-description'>
            Send your users a special offer everytime they send a custom hashtag
          </p>
        </div>

        <hr className='line'/>

        <div className='response-info'>
          <h4>Responses to:</h4>
          <SignalIcon type="twitter" />
          {this.editSignalName()}
          <SaveBtn data={signal}/>
          <AddBtn
            type='add'
            setResponse={this.setResponse}
            expirationDate={signal.expirationDate}
          />
        </div>

        <div className='tip-box'>
          <SignalIcon type="tip"/>
          <h5>Tip</h5>
          <p> Add your offer responses here, be sure to include a link or details on how to use the offer.
              When you’re ready, activate your signal and promote it </p>
        </div>

        <div className='response-edit-box'>
          <div className='response-text'>
            <h5>First Response</h5>
            <p>Users will see this response the first time they use your signal</p>
          </div>
          <InputBox
            name="responses[0].message"
            placeholder="Type your response here"
            componentClass="textarea"
            data={this.state.firstResponse}
          />
          <span className='required'>REQUIRED</span>
        </div>

        <div className='response-edit-box'>
          <div className='response-text'>
            <h5>Not Available/ Repeat Requests</h5>
          </div>
          <InputBox
            name="responses[1].message"
            placeholder="Type your response here"
            componentClass="textarea"
            data={this.state.repeatResponse}
          />
          <span className='required'>REQUIRED</span>
        </div>
      </div>
    );
  }
}

