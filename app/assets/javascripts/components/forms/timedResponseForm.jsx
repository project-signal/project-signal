import React, { Component } from 'react';
import InputBox from 'components/forms/inputBox.jsx';
import Calendar from 'components/forms/calendar.jsx';
import _ from 'lodash';

function renderFields({ fields, meta: { touched, error } }) {
  return fields.map((response, index) => {
    return (
      <div className='response-edit-box' key={index}>
        <div className='response-text'>
          <h5>Response</h5>
          <span className='timed-response-box-label'>
            <p>Expires on:</p>
            <Calendar
              name={`${response}.expiration_date`}
            />
          </span>
        </div>
        <InputBox
          name={`${response}.message`}
          placeholder="Type in a response here, add website links too"
          componentClass="textarea"
        />
        { touched && error && <span className='input-form-error'>{error}</span> }
        <a onClick={()=> fields.remove(index)} className='delete-timed-response-btn'>
          delete
        </a>
      </div>
    );
  });
}

export default function TimedResponseForm({ ...props }) {
  return <div>{renderFields(props)}</div>;
}
