import Ember from 'ember';

export default Ember.Service.extend({
  store: Ember.inject.service(),
  _init: function() {
    this.set('data', this.get('store').findAll('issue'));
  }.on('init')
});
