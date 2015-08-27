import Ember from 'ember';

export default Ember.Component.extend({
  sustainableDevelopmentGoals: Ember.inject.service(),

  _onInsertElement: function() {
    this.get('sustainableDevelopmentGoals.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
