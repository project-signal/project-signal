import React, { Component } from 'react';
import SignalIcon from '../../../../../links/signal_icon.jsx';
import ImageUpload from './image_upload.jsx';
import _ from 'lodash';
import {
  Button,
  FormControl,
} from 'react-bootstrap';

export default class Promote extends Component {
  constructor(props) {
    super(props);
    this.handleChange = this.handleChange.bind(this); 
    this.handleSubmit = this.handleSubmit.bind(this);  
    this.showPromoImage = this.showPromoImage.bind(this); 

    var promoTweet = props.signal.edit.promotional_tweet;

    if (_.isEmpty(promoTweet)) {
      this.state = {
        promoTweetId: '',
        message: '',
        imageUrl: ''
      };
    } else {
      this.state = {
        promoTweetId: promoTweet.id,
        message: promoTweet.message,
        url: promoTweet.url
      }
    }
  }

  handleChange(e) {
    this.setState({message: e.currentTarget.value});
  }

  handleSubmit() {
    this.createPromoTweet(this.state);
  }

  createPromoTweet(msg) {
    $.ajax({
      type: 'POST',
      url: '/api/v1/post_tweet',
      data: {
        signal_id: this.props.signal.edit.id,
        message: this.state.message
      }
    }).done((result) => {
      console.log('sucesss');
      console.log(result);
    }).fail((jqXhr) => {
      console.log('failed request');
    });
  }

  showPromoImage() {
    if (this.state.url) {
      return (
        <img 
          src={ this.state.url }
          className='promo-image-preview'
        />
      );
    }
  }

  render() {
    return (
      <div className='col-md-9 content-box'>
        <div className='content-header'>
          <p className='signal-type-label'> SEND TWEET </p>
        </div>

        <div className='response-info'>
          <h4>Promote:</h4>
          <SignalIcon type='twitter'/>
          <h4 className='subheading'>@Brand #Offers</h4>
        </div>

        <div className='tip-box'>
          <SignalIcon type='tip'/>
          <h5>Tip</h5>
          <p> Increase the awareness of your signal, promote it to your audience </p>
        </div>

        <div className='promote-box'>
          <div className='response-text'>
            <h5>Promotional Tweet</h5>
            <p>140 Character Limit</p>
          </div>

          <div className='input-box'>
            <FormControl onChange={this.handleChange} componentClass="textarea" placeholder={'Searching for deals any time? Tweet or message #Deals to @Brand'}/>
          </div>

          <div className='subheader'>
            <h5 className='subheader'>Promotional Image</h5>
            <p>Select an image to include or upload your own</p>
          </div>

          <div className='row'>
            <div className='col-xs-12 col-sm-12 col-md-12 col-lg-12 center promote-image'>
              { this.showPromoImage() }
              <ImageUpload signal={this.props.signal.edit}/>
            </div>
          </div>

          <Button onClick={this.handleSubmit} type='submit' className='save-btn post-to-timeline-btn'>POST TO YOUR TIMELINE</Button>
        </div>
      </div>
    );
  }
}
