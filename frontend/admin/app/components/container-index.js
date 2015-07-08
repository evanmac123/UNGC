import Ember from 'ember';

export default Ember.Component.extend({
  _scrollTop: function() {
    Ember.run.later(function() {
      Ember.$('body').scrollTop(0);
    }, 20);
  }.on('didInsertElement')
});
