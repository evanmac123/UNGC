import Ember from 'ember';
import request from 'ic-ajax';

export default Ember.Route.extend({
  store: Ember.inject.service(),
  contacts: Ember.inject.service(),

  model() {
    return this.store.find('contact', 'current');
  },

  setupController(controller, model) {
    this.set('contacts.current', model);
  },

  actions: {
    logout() {
      request('/logout', {type: 'DELETE'}).then( () => window.location.href = window.location.href );
    }
  }
});

