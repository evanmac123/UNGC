import Ember from 'ember';
import DS from 'ember-data';
import request from 'ic-ajax';

export default Ember.Object.extend({
  _init: function() {
    const store = this.container.lookup('store:main');
    this.set('data', store.find('topic'));
  }.on('init')
});
