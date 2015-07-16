import Ember from 'ember';

export default Ember.Component.extend({
  active: true,
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
      this.set('active', false);
      Ember.run.next(() => { this.set('active', true);});
      this.sendAction('setDraftFromPayload', payload);
    }
  }
});
