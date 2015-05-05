import Ember from 'ember';
import request from 'ic-ajax';

export default Ember.Route.extend({
  actions: {
    logout() {
      request('/logout', {type: 'DELETE'}).then( () => window.location.href = window.location.href );
    }
  }
});

