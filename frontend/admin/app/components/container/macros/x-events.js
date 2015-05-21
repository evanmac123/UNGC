import Ember from 'ember';

export default Ember.Component.extend({
  eventList: Ember.inject.service('event-list'),

  _onInsertElement: function() {
    this.get('eventList.data').then( (data) => {
      this.set('items', data);
    });
  }.on('didInsertElement')
});
