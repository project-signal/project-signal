import _ from 'lodash';
import { handleActions } from 'redux-actions';
import {
  normalizeListenSignalsResponse,
  normalizeListenSignalResponse,
} from 'util/normalize';
import {
  LISTEN_SIGNALS_REQUEST,
  LISTEN_SIGNALS_REQUEST_SUCCESS,
  LISTEN_SIGNALS_REQUEST_FAIL,
  LISTEN_SIGNALS_UPDATE_REQUEST_SUCCESS,
  LISTEN_SIGNALS_CREATE_REQUEST_SUCCESS,
  LISTEN_SIGNALS_CREATE_REQUEST_FAIL,
  LISTEN_SIGNALS_DELETE_REQUEST_SUCCESS,
} from 'redux/modules/models/listenSignals';


/*
* Initial State
*/
export const initialState = {
  data: {},
  loaded: false,
  loading: false,
};

function handleResponseRequest(state, action) {
  const normalizedResponse = normalizeListenSignalResponse(action.payload);
  const responses = _.get(normalizedResponse, 'entities.responses', {});

  return {
    ...state,
    data: {
      ..._.get(state, 'data', {}),
      ...responses,
    }
  };
}

/*
* Reducer
*/
export const reducer = handleActions({
  [LISTEN_SIGNALS_REQUEST]: (state, action) => ({
    ...state,
    loading: true,
    loaded: false,
  }),

  [LISTEN_SIGNALS_REQUEST_SUCCESS]: (state, action) => ({
    ...state,
    data: _.get(normalizeListenSignalsResponse(action.payload), 'entities.responses', {}),
    loading: false,
    loaded: true,
  }),

  [LISTEN_SIGNALS_REQUEST_FAIL]: (state, action) => ({
    ...state,
    error: action.payload,
    loading: false,
    loaded: false,
  }),

  [LISTEN_SIGNALS_UPDATE_REQUEST_SUCCESS]: handleResponseRequest,

  [LISTEN_SIGNALS_CREATE_REQUEST_SUCCESS]: handleResponseRequest,

  [LISTEN_SIGNALS_DELETE_REQUEST_SUCCESS]: (state, action) => {
    const responses = action.meta.signal.responses;
    const responseIds = _.map(responses, (response) => {
      return response.id;
    });

    return {
      ...state,
      data: _.omit(state.data, responseIds),
    }
  },
}, initialState);
