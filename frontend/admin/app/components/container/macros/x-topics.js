import Ember from 'ember';

export default Ember.Component.extend({
  topics: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('topics.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
