import Ember from 'ember';

export default Ember.Object.extend({
  current: null,

  _init: function() {
    const store = this.container.lookup('store:main');
    this.set('data', store.find('contact'));
  }.on('init')
});
