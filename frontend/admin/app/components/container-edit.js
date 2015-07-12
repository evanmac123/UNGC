import Ember from 'ember';

export default Ember.Component.extend({
  _scrollTop: function() {
    Ember.run.later(function() {
      Ember.$('body').scrollTop(0);
    }, 20);
  }.on('didInsertElement'),

  actions: {
    publish(container) {
      this.sendAction('publish', container);
    },
    saveDraft(container) {
      this.sendAction('saveDraft', container);
    },
    destroyModel(container) {
      this.sendAction('destroyModel', container);
    },
    setDraftFromPayload(payload) {
      this.sendAction('setDraftFromPayload', payload);
    }
  }
});
