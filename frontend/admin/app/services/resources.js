import Ember from 'ember';

export default Ember.Object.extend({
  _init: function() {
    const store = this.container.lookup('store:main');
    this.set('data', store.find('resource'));
  }.on('init')
});
