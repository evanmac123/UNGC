import Ember from 'ember';

export default Ember.Service.extend({
  current: null,
  store: Ember.inject.service(),
  _init: function() {
    this.set('data', this.get('store').findAll('contact'));
  }.on('init')
});
