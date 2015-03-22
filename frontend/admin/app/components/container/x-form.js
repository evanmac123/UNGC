import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'form',
  record: null,

  templatePathForLayout: function() {
    var layout = this.get('record.layout');

    if (layout) {
      return `containers/_forms/${layout}`;
    } else {
      return null;
    }
  }.property('record.layout'),

  sendSubmitAction: function(event) {
    event.preventDefault();
    this.sendAction('submit', this.get('record'));
    return false;
  }.on('submit')
});
