import Ember from 'ember';

export default Ember.Component.extend({
  issues: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('issues.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});

